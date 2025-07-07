# app/channels/application_cable/connection.rb
require "ostruct"
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      return nil if token.blank?

      begin
        payload, _ = JWT.decode(token, jwt_secret, true, { algorithm: "HS256" })
         # puts "✅ payload: #{payload}"

         OpenStruct.new(payload)  # Aqui estava o erro!
      rescue JWT::DecodeError => e
        Rails.logger.warn("WebSocket JWT inválido: #{e.message}")
        nil
      end
    end

    def jwt_secret
      ENV["SERV_KEYS"] || "chave_secreta_de_teste"
    end
  end
end
