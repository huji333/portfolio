require 'rails_helper'

RSpec.describe TodoItem do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:position) }
  it { is_expected.to have_many(:todo_likes).dependent(:destroy) }
end
