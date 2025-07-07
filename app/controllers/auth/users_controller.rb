# app/controllers/auth/users_controller.rb
module Auth
  class UsersController < ApplicationController
    include BearerToken
    include MongoBody

    def users
      filter = body["filter"] || {}
      options = body["options"] || {}

      return unless on_object_id(filter)

      begin
        users = on_find(filter, options)
        result = users.map { |u| User.from(u) }
        # puts "✅ result: #{result}"
        render json: result, status: 200
      rescue => e
        render json: { error: e.message }, status: 500
      end
    end

    private

    def on_find(filter, options)
      result = MongoDB.usuarios.find(filter, options).to_a
      raise "Usuário não encontrado!" if result.empty?
      result
    end
  end
end
