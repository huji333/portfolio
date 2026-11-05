class Users::SessionsController < Devise::SessionsController
  include AuthRateLimit

  limit_auth_attempts only: :create
end
