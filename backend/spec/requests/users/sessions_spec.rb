require 'rails_helper'

RSpec.describe 'Login rate limiting', type: :request do
  before { Users::SessionsController::RATE_LIMIT_STORE.clear }
  after { Users::SessionsController::RATE_LIMIT_STORE.clear }

  let(:user) { create(:user, :admin) }

  describe 'POST /users/sign_in' do
    let(:bad_credentials) { { user: { email: user.email, password: 'wrong-password' } } }

    it 'returns 429 once the attempt limit is exceeded' do
      Users::SessionsController::MAX_LOGIN_ATTEMPTS.times do
        post user_session_path, params: bad_credentials
        expect(response).not_to have_http_status(:too_many_requests)
      end

      post user_session_path, params: bad_credentials

      expect(response).to have_http_status(:too_many_requests)
    end

    it 'lets a correct login through below the limit' do
      post user_session_path, params: { user: { email: user.email, password: user.password } }

      expect(response).to have_http_status(:see_other).or have_http_status(:found)
      expect(controller.current_user).to eq(user)
    end
  end

  # mailer 未設定のまま再設定メールの申請を受けると 500 になっていたため、機能ごと外している
  it 'does not expose the password reset routes' do
    expect(Rails.application.routes.url_helpers).not_to respond_to(:user_password_path)
  end
end
