# /app/lib/bearer_token.rb
module BearerToken
  extend ActiveSupport::Concern

  included do
    before_action :authorize_token
  end

  private

  def authorize_token
    auth = request.headers["Authorization"]
    # puts "✅ auth: #{auth}"

    unless auth&.start_with?("Bearer ")
      render json: { error: "Autenticação obrigatória!" }, status: 401 and return
    end

    token = auth.split(" ")[1]
    # puts "✅ token: #{token}"

    begin
      payload = JWT.decode(token, jwt_secret, true, { algorithm: "HS256" })

      # Ex: colocar no request para usar depois
      @current_user = payload[0]
    rescue JWT::ExpiredSignature, JWT::DecodeError
      render json: { error: "Token inválido ou expirado" }, status: 403 and return
    end
  end

  def jwt_secret
    ENV["SERV_KEYS"] || "chave_secreta_de_teste"
  end
end
