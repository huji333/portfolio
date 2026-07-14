require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project) { build(:project) }
  let(:cdn_base_url) { Rails.configuration.cdn_base_url }

  describe 'validations' do
    context 'title' do
      it 'is valid with a title' do
        project.title = 'Portfolio Site'
        expect(project).to be_valid
      end

      it 'is invalid when title is blank' do
        project.title = ''
        expect(project).to be_invalid
      end
    end

    context 'link' do
      it 'is valid with a link' do
        project.link = 'https://example.com'
        expect(project).to be_valid
      end

      it 'is invalid when link is blank' do
        project.link = ''
        expect(project).to be_invalid
      end
    end
  end

  describe '#tags=' do
    it 'splits a comma-separated string into a trimmed array' do
      project.tags = 'Rails, Next.js , PostgreSQL'
      expect(project.tags).to eq(%w[Rails Next.js PostgreSQL])
    end

    it 'rejects empty entries from surplus commas' do
      project.tags = 'Rails, , ,Next.js,'
      expect(project.tags).to eq(%w[Rails Next.js])
    end

    it 'accepts an array as-is' do
      project.tags = %w[Rails Next.js]
      expect(project.tags).to eq(%w[Rails Next.js])
    end

    it 'defaults to an empty array' do
      expect(build(:project).tags).to eq([])
    end
  end

  # file_url は variant_url のフォールバック専用の private ヘルパーなので send で検証する。
  describe '#file_url' do
    context 'when file is not attached' do
      it 'returns nil' do
        expect(project.send(:file_url)).to be_nil
      end
    end

    context 'when a file is attached' do
      it 'returns the CDN-backed url' do
        file = double('ActiveStorage::Attached::One', attached?: true, key: 'projects/file-key')
        allow(project).to receive(:file).and_return(file)

        expect(project.send(:file_url)).to eq("#{cdn_base_url}/projects/file-key")
      end
    end
  end
end
