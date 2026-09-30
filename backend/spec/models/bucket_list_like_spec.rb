require 'rails_helper'

RSpec.describe BucketListLike do
  it 'rejects duplicate likes at the DB level' do
    like = create(:bucket_list_like)
    expect do
      create(:bucket_list_like, bucket_list_item: like.bucket_list_item, device_uuid: like.device_uuid)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
