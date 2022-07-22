# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # アクセスを許可するオリジン（フロントのアドレス）を指定
    origins "http://localhost:3000", "本番環境でのアドレス"
    
    resource '*',
      :headers => :any,
      # ユーザー認証関連
      :expose => ['access-token', 'expiry', 'token-type', 'uid', 'client'],

      # リソースに対して許可するHTTPリクエストメソッドを指定
      :methods => [:get, :post, :options, :delete, :put, :head, :patch],

      # Cookieを利用する場合は以下を記述
      :credentials => true
  end
end
