class BucketListItem < ApplicationRecord
  has_many :bucket_list_likes, dependent: :destroy

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:position, :id) }

  # 新規作成時の採番用。position は admin index のドラッグでのみ変更する
  def self.next_position
    (maximum(:position) || -1) + 1
  end

  # admin index のドラッグ並び替えから呼ばれ、渡された順で position を 0..N-1 に振り直す
  def self.reorder_positions!(ids)
    items = where(id: ids).index_by(&:id)
    raise ActiveRecord::RecordNotFound, 'Some bucket list items not found' if items.size != ids.uniq.size

    transaction do
      ids.each_with_index { |id, index| items.fetch(id).update!(position: index) }
    end
  end

  # 公開 API のレスポンス表現。一覧といいねトグルの2エンドポイントで
  # 同じ shape を返すためここに一本化する
  def api_json(liked:)
    as_json(only: %i[id title note done likes_count]).merge(liked: liked)
  end
end
