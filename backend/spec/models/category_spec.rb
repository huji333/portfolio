require 'rails_helper'

RSpec.describe Category, type: :model do
  it 'rejects a name that duplicates an existing one case-insensitively' do
    create(:category, name: 'Landscape')
    category = build(:category, name: 'landscape')

    expect(category).to be_invalid
  end
end
