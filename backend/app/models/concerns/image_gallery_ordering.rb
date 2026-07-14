# 画像ギャラリーの並び順（featured pin + taken_at 時系列）とキュレーション操作を集約する。
# 設計は #273: 手動キュレーションは featured_rank 1本、基本順は taken_at 由来。
module ImageGalleryOrdering
  extend ActiveSupport::Concern

  included do
    # 手動キュレーション（featured）。featured_rank ASC が表示順。
    scope :featured, -> { where.not(featured_rank: nil).order(:featured_rank) }
  end

  # ActiveSupport::Concern はネストした ClassMethods モジュールを自動で extend する。
  # class_methods ブロックにすると Metrics/BlockLength に抵触するため module 定義にする。
  module ClassMethods
    # ギャラリーの並びは2段構成：featured を featured_rank ASC で先頭に pin し、
    # 続けて非 featured を taken_at DESC（時系列）で並べる。featured は時系列側に
    # 重複して出さない（時系列セグメントは featured_rank IS NULL のみ）。
    #
    # cursor は2セグメント keyset の自己記述形式:
    #   featured セグメント内: "f,<featured_rank>,<id>"
    #   時系列セグメント内:   "t,<taken_at のエポックミリ秒>,<id>"
    # featured セグメントを取り切ったら時系列セグメントへ続きから遷移する。
    def for_gallery(category_ids: nil, cursor: nil, limit: 20)
      base = published.filter_by_categories(category_ids).with_attached_file.includes(:camera, :lens)
      parsed_cursor = parse_gallery_cursor(cursor)
      remaining = limit + 1

      results = gallery_featured_segment(base, parsed_cursor, remaining)
      remaining -= results.size
      results.concat(gallery_timeline_segment(base, parsed_cursor, remaining)) if remaining.positive?
      results
    end

    # cursor 文字列を { segment:, value:, id: } にパースする。不正な形式は nil（先頭から）。
    def parse_gallery_cursor(cursor)
      return nil if cursor.blank?

      segment, value, id = cursor.split(",")
      return nil unless %w[f t].include?(segment) && value.present? && id.present?
      return nil unless value.match?(/\A-?\d+\z/) && id.match?(/\A-?\d+\z/)

      { segment: segment == "f" ? :featured : :timeline, value: value.to_i, id: id.to_i }
    end

    # featured リストの並び替え。渡した順に 0..N-1 へ正規化する。
    # 含まれない画像（対象外）はそのまま：featured 解除もランクの変更もしない。
    def reorder_featured!(ids)
      images = where(id: ids).index_by(&:id)
      raise ActiveRecord::RecordNotFound, 'Some images not found' if images.size != ids.uniq.size

      transaction do
        ids.each_with_index { |id, index| images.fetch(id).update!(featured_rank: index) }
      end
    end

    private

    def gallery_featured_segment(base, parsed_cursor, remaining)
      return [] unless parsed_cursor.nil? || parsed_cursor[:segment] == :featured

      scope = base.featured
      scope = scope.where("(featured_rank, id) > (?, ?)", parsed_cursor[:value], parsed_cursor[:id]) if parsed_cursor
      scope.limit(remaining).to_a
    end

    def gallery_timeline_segment(base, parsed_cursor, remaining)
      scope = base.where(featured_rank: nil).order(taken_at: :desc, id: :desc)
      if parsed_cursor && parsed_cursor[:segment] == :timeline
        taken_at_value = Time.zone.at(parsed_cursor[:value] / 1000.0)
        scope = scope.where("(taken_at, id) < (?, ?)", taken_at_value, parsed_cursor[:id])
      end
      scope.limit(remaining).to_a
    end
  end

  # featured の末尾に追加する。既に featured なら何もしない。
  def feature!
    return if featured_rank.present?

    update!(featured_rank: self.class.featured.count)
  end

  # featured を解除し、残りの featured_rank を 0..N-1 へ詰め直す。
  def unfeature!
    return if featured_rank.blank?

    self.class.transaction do
      update!(featured_rank: nil)
      self.class.featured.each_with_index { |image, index| image.update!(featured_rank: index) }
    end
  end

  # 編集フォームの featured トグル用の仮想属性（featured_rank の有無から導出）。
  def featured?
    featured_rank.present?
  end
  alias is_featured featured?
end
