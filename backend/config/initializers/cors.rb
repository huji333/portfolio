Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['FRONTEND_ORIGIN'] || "http://localhost:3002"
    resource "/api/*",
             headers: %w[Content-Type Accept Authorization],
             # /api 配下は書き込みエンドポイント（いいね等）を含むため GET 系以外も許可
             methods: %i[get post delete options head]
  end
end
