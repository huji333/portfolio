require 'rails_helper'

RSpec.describe 'Direct uploads', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:path) { '/rails/active_storage/direct_uploads' }
  let(:params) do
    {
      blob: {
        filename: 'photo.jpg',
        byte_size: 4,
        checksum: Digest::MD5.base64digest('test'),
        content_type: 'image/jpeg'
      }
    }
  end
  let(:json_headers) { { 'Accept' => 'application/json' } }

  it 'keeps the named route that forms use pointing at the guarded path' do
    expect(Rails.application.routes.url_helpers.rails_direct_uploads_path).to eq(path)
  end

  context 'when not signed in' do
    it 'rejects the upload without creating a blob' do
      expect { post path, params:, headers: json_headers, as: :json }
        .not_to change(ActiveStorage::Blob, :count)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when signed in as a non-admin user' do
    before { sign_in create(:user, role: 'guest') }

    it 'rejects the upload without creating a blob' do
      expect { post path, params:, headers: json_headers, as: :json }
        .not_to change(ActiveStorage::Blob, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when signed in as an admin' do
    before { sign_in create(:user, :admin) }

    it 'creates a blob and returns direct upload info' do
      expect { post path, params:, headers: json_headers, as: :json }
        .to change(ActiveStorage::Blob, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include('signed_id', 'direct_upload')
    end
  end
end
