# CdnAttachedFile を include するモデル（Image / Project）の添付は
# ProcessAttachedFileJob が analyze まで担うため、attach 時に ActiveStorage が
# 自動 enqueue する AnalyzeJob（無条件 blob.analyze → S3 GET + フルデコード）は
# まるごと二重処理になる。該当モデルの添付に限り enqueue 自体を抑止する（#276）。
#
# NOTE: private メソッド analyze_blob_later（after_create_commit フック）の上書き。
# Rails 更新でフック名が変われば prepend が空振りして標準動作（余分な解析）に
# 戻るだけで、機能は壊れない。
module SkipBuiltinAnalyzeJobForCdnAttachedFile
  private

  def analyze_blob_later
    return if record.is_a?(CdnAttachedFile)

    super
  end
end

ActiveSupport.on_load(:active_storage_attachment) do
  prepend SkipBuiltinAnalyzeJobForCdnAttachedFile
end
