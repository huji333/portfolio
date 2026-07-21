namespace :storage do
  desc "Verify every ActiveStorage::VariantRecord's image actually exists in the storage " \
       'service (S3). See #240: a failed upload can leave a VariantRecord/blob row without a ' \
       "backing object, and variant_generated? (DB-only) can't detect that on its own. " \
       'Pass FIX=1 to repair (re-generates via the standard processing path).'
  task verify_variants: :environment do
    verify_variants!(fix: ENV['FIX'] == '1')
  end
end

def verify_variants!(fix:)
  checked = 0
  missing_ids = []

  ActiveStorage::VariantRecord.includes(:blob, image_attachment: :blob).find_each do |variant_record|
    checked += 1
    next if variant_exists_on_storage?(variant_record)

    missing_ids << variant_record.id
    report_missing_variant(variant_record)
    repair_variant_record!(variant_record) if fix
  end

  puts "storage:verify_variants: checked #{checked}, missing #{missing_ids.size}" \
       "#{' (repaired)' if fix}."

  return unless missing_ids.any? && !fix

  abort "storage:verify_variants: #{missing_ids.size} variant(s) missing from S3 " \
        "(ids=#{missing_ids.join(',')}). Re-run with FIX=1 to repair."
end

def variant_exists_on_storage?(variant_record)
  image = variant_record.image
  image.attached? && image.service.exist?(image.key)
end

def report_missing_variant(variant_record)
  key = variant_record.image.attached? ? variant_record.image.key : '(no image attached)'
  puts "  missing: variant_record=#{variant_record.id} key=#{key} " \
       "owner_blob=#{variant_record.blob_id} owner_filename=#{variant_record.blob.filename}"
end

# variation_digest から元の resize パラメータ（resize_to_limit 等）を厳密に復元して
# 直接 processed を呼び直すのは、Variation のシリアライズ形式に依存し壊れやすい。
# よりシンプルで確実な方法を選ぶ: 孤児化した VariantRecord（と image の attachment）を
# 破棄し、所有側レコード（Image/Project）の ProcessAttachedFileJob を再エンキューして、
# 標準経路（CdnAttachedFile#ensure_variant_processed）にすべての variant を再生成させる。
def repair_variant_record!(variant_record)
  owners = variant_record.blob.attachments.filter_map(&:record).uniq

  variant_record.image.purge if variant_record.image.attached?
  variant_record.destroy!

  owners.each do |owner|
    puts "  -> re-enqueuing ProcessAttachedFileJob for #{owner.class.name}##{owner.id}"
    ProcessAttachedFileJob.perform_later(owner)
  end
end
