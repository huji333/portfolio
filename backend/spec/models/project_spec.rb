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

    context 'when file url can be generated' do
      it 'returns the blob url' do
        filename = instance_double(ActiveStorage::Filename)
        blob = instance_double(ActiveStorage::Blob)
        file = double('ActiveStorage::Attached::One', attached?: true, blob: blob)
        expected_url = 'https://example.com/project.pdf'

        allow(project).to receive(:file).and_return(file)
        allow(file).to receive(:filename).and_return(filename)
        allow(blob).to receive(:filename).and_return(filename)
        allow(blob).to receive(:url).with(hash_including(:expires_in, :disposition, :filename)).and_return(expected_url)

        expect(project.file_url).to eq(expected_url)
      end
    end

    context 'when generating the url raises an error' do
      it 'logs the error and returns nil' do
        filename = instance_double(ActiveStorage::Filename)
        blob = instance_double(ActiveStorage::Blob)
        file = double('ActiveStorage::Attached::One', attached?: true, blob: blob)

        allow(project).to receive(:file).and_return(file)
        allow(file).to receive(:filename).and_return(filename)
        allow(blob).to receive(:filename).and_return(filename)
        allow(blob).to receive(:url).and_raise(StandardError.new('boom'))
        allow(Rails.logger).to receive(:error)

        expect(project.file_url).to be_nil
        expect(Rails.logger).to have_received(:error).with(include('file_url error (project'))
      end
    end
  end
end
