Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['FRONTEND_ORIGIN'] || "http://localhost:3002"
    resource "*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: %w[access-token expiry token-type uid client]
  end
end
