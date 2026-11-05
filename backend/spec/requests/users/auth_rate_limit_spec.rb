require 'rails_helper'

RSpec.describe 'Auth rate limiting', type: :request do
  before { AuthRateLimit::STORE.clear }
  after { AuthRateLimit::STORE.clear }

  let(:user) { create(:user, :admin) }

  describe 'POST /users/sign_in' do
    let(:bad_credentials) { { user: { email: user.email, password: 'wrong-password' } } }

    it 'returns 429 once the attempt limit is exceeded' do
      AuthRateLimit::MAX_ATTEMPTS.times do
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

  describe 'POST /users/password' do
    # 存在しない email でもリクエストは数える（メールは送らないので mailer の設定に依存しない）
    let(:reset_params) { { user: { email: 'nobody@example.com' } } }

    it 'returns 429 once the reset request limit is exceeded' do
      AuthRateLimit::MAX_ATTEMPTS.times do
        post user_password_path, params: reset_params
        expect(response).not_to have_http_status(:too_many_requests)
      end

      post user_password_path, params: reset_params

      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
