require 'rails_helper'

RSpec.describe Admin::ImagesController, type: :request do
  let(:admin) { create(:user, :admin) }
  let(:guest) { create(:user) }
  let(:image) { create(:image) }
  let(:camera) { create(:camera) }
  let(:lens) { create(:lens) }
  let(:valid_attributes) do
    {
      title: 'Sample Image',
      file: fixture_file_upload('spec/fixtures/files/sample.jpg', 'image/jpeg'),
      caption: 'This is a sample caption',
      taken_at: Time.zone.now,
      camera_id: camera.id,
      lens_id: lens.id,
      display_order: 1,
      is_published: true
    }
  end

  let(:invalid_attributes) do
    {
      title: '',
      file: fixture_file_upload('spec/fixtures/files/sample.jpg', 'image/jpeg'),
      caption: '',
      taken_at: Time.zone.now,
      camera_id: camera.id,
      lens_id: lens.id,
      display_order: 1,
      is_published: true
    }
  end

  describe 'GET /admin/images' do
    context 'when user is admin' do
      before { sign_in admin }

      it 'returns a success response' do
        get admin_images_path
        expect(response).to be_successful
      end
    end

    context 'when user is guest' do
      before { sign_in guest }

      it 'returns an unauthorized error' do
        get admin_images_path
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get admin_images_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /admin/images/:id' do
    context 'when user is admin' do
      before { sign_in admin }

      it 'returns a success response' do
        get admin_image_path(image)
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /admin/images/new' do
    context 'when user is admin' do
      before { sign_in admin }

      it 'returns a success response' do
        get new_admin_image_path
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /admin/images' do
    context 'when user is admin' do
      before { sign_in admin }

      context 'with valid params' do
        it 'creates a new Image' do
          expect do
            post admin_images_path, params: { image: valid_attributes }
          end.to change(Image, :count).by(1)
        end

        it 'sets the correct title' do
          post admin_images_path, params: { image: valid_attributes }
          expect(Image.last.title).to eq('Sample Image')
        end

        it 'redirects to the images list' do
          post admin_images_path, params: { image: valid_attributes }
          expect(response).to redirect_to(admin_images_path)
        end
      end

      context 'with invalid params' do
        it 'does not create a new Image' do
          expect do
            post admin_images_path, params: { image: invalid_attributes }
          end.not_to change(Image, :count)
        end

        it 'redirects to the new form' do
          post admin_images_path, params: { image: invalid_attributes }
          expect(response).to redirect_to(new_admin_image_path)
        end
      end
    end
  end

  describe 'GET /admin/images/:id/edit' do
    context 'when user is admin' do
      before { sign_in admin }

      it 'returns a success response' do
        get edit_admin_image_path(image)
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /admin/images/:id' do
    context 'when user is admin' do
      before { sign_in admin }

      context 'with valid params' do
        let(:new_attributes) { { title: 'New Title' } }

        it 'updates the requested image' do
          patch admin_image_path(image), params: { image: new_attributes }
          image.reload
          expect(image.title).to eq('New Title')
        end

        it 'redirects to the image' do
          patch admin_image_path(image), params: { image: new_attributes }
          expect(response).to redirect_to(admin_image_path(image))
        end
      end

      context 'with invalid params' do
        it 'returns a success response (i.e. to display the edit template)' do
          patch admin_image_path(image), params: { image: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end
  end

  describe 'DELETE /admin/images/:id' do
    context 'when user is admin' do
      before { sign_in admin }

      it 'destroys the requested image' do
        image_to_delete = create(:image)
        expect do
          delete admin_image_path(image_to_delete)
        end.to change(Image, :count).by(-1)
      end

      it 'redirects to the images list' do
        delete admin_image_path(image)
        expect(response).to redirect_to(admin_images_path)
      end
    end
  end
end
