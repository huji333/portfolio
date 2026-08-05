require 'rails_helper'

RSpec.describe TodoLike do
  subject { build(:todo_like) }

  it { is_expected.to validate_presence_of(:device_uuid) }

  it 'rejects duplicate likes at the DB level' do
    like = create(:todo_like)
    expect do
      create(:todo_like, todo_item: like.todo_item, device_uuid: like.device_uuid)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'keeps likes_count in sync on create and destroy' do
    item = create(:todo_item)
    like = create(:todo_like, todo_item: item)
    expect(item.reload.likes_count).to eq(1)

    like.destroy!
    expect(item.reload.likes_count).to eq(0)
  end
end
