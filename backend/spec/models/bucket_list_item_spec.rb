require 'rails_helper'

RSpec.describe BucketListItem do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:position) }
  it { is_expected.to have_many(:bucket_list_likes).dependent(:destroy) }
end
