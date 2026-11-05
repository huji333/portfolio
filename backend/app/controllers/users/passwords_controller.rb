class Users::PasswordsController < Devise::PasswordsController
  include AuthRateLimit

  # create: 再設定メールの送信、update: トークンでの再設定
  limit_auth_attempts only: %i[create update]
end
