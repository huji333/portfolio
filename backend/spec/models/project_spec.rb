require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project) { build(:project) }

  describe 'validations' do
    context 'link' do
      it 'is valid with an http or https link' do
        project.link = 'https://example.com'
        expect(project).to be_valid

        project.link = 'http://example.com'
        expect(project).to be_valid
      end

      it 'is invalid with a non-http(s) or malformed link' do
        %w[javascript:alert(1) ftp://x example.com].each do |link|
          project.link = link
          expect(project).to be_invalid
        end

        project.link = 'https://example.com/path with space'
        expect(project).to be_invalid
      end
    end
  end

  describe '#tags=' do
    it 'normalizes a comma-separated string, passes arrays through, and defaults to []' do
      project.tags = 'Rails, Next.js , PostgreSQL'
      expect(project.tags).to eq(%w[Rails Next.js PostgreSQL])

      project.tags = 'Rails, , ,Next.js,'
      expect(project.tags).to eq(%w[Rails Next.js])

      project.tags = %w[Rails Next.js]
      expect(project.tags).to eq(%w[Rails Next.js])

      expect(build(:project).tags).to eq([])
    end
  end
end
