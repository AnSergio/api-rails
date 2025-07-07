# app/controllers/auth/user_controller.rb
module Auth
  class UserController < ApplicationController
    include BearerToken
    include MongoBody

    def user
      filter = body["filter"] || {}

      if filter["_id"].blank? && filter["nome"].blank?
        return render json: { error: "Filtro ID ou Usuário é obrigatório!" }, status: 400
      end

      return unless on_object_id(filter)

      begin
        result = on_find_one(filter)
        user = User.from(result)
        # puts "✅ user: #{user}"
        render json: { usuario: user }, status: 200

      rescue => e
        render json: { error: e.message }, status: 500
      end
    end

    private

    def on_find_one(filter)
      result = MongoDB.usuarios.find(filter).first
      raise "Usuário não encontrado!" if result.nil?
      result
    end
  end
end
