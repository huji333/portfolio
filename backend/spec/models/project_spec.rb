require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project) { build(:project) }

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

  describe '#file_url' do
    context 'when file is not attached' do
      it 'returns nil' do
        expect(project.file_url).to be_nil
      end
    end

    context 'when a file is attached' do
      it 'returns the CDN-backed url' do
        file = double('ActiveStorage::Attached::One', attached?: true, key: 'projects/file-key')
        allow(project).to receive(:file).and_return(file)

        expect(project.file_url).to eq('https://cdn.example.test/projects/file-key')
      end
    end
  end
end
