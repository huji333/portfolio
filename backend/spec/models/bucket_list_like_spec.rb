require 'rails_helper'

RSpec.describe BucketListLike do
  subject { build(:bucket_list_like) }

  it { is_expected.to validate_presence_of(:device_uuid) }

  it 'rejects duplicate likes at the DB level' do
    like = create(:bucket_list_like)
    expect do
      create(:bucket_list_like, bucket_list_item: like.bucket_list_item, device_uuid: like.device_uuid)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'keeps likes_count in sync on create and destroy' do
    item = create(:bucket_list_item)
    like = create(:bucket_list_like, bucket_list_item: item)
    expect(item.reload.likes_count).to eq(1)

    like.destroy!
    expect(item.reload.likes_count).to eq(0)
  end
end
