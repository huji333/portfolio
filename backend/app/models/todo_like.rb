class TodoLike < ApplicationRecord
  belongs_to :todo_item, counter_cache: :likes_count

  # device_uuid はフロント生成の識別子。形式は強制しないが、公開エンドポイント
  # なので長さだけ制限する。重複防止は DB の unique index が担う
  # （uniqueness バリデーションを足すと create_or_find_by! が DB に届く前に
  #  RecordInvalid になり冪等にならない）
  validates :device_uuid, presence: true, length: { maximum: 64 }
end
