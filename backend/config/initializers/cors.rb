Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['FRONTEND_ORIGIN'] || "http://localhost:3002"
    resource "/api/*",
             headers: %w[Content-Type Accept Authorization],
             methods: %i[get post options head]
  end
end
