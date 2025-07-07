# app/controllers/auth/login_controller.rb
module Auth
  class LoginController < ApplicationController
    include BasicAuth

    def login
      name, pass = decode_basic_auth
      return render json: { error: "Nome e Senha é necessário!" }, status: 400 if name.blank? || pass.blank?

      begin
        result = on_auth_nome(name)
        user = User.from(result)
        # puts "✅ user: #{user}"

        return render json: { error: "Credenciais inválidas!" }, status: 401 if user.senha != pass

        token = jwt_token(user)
        rots = Rots.from(result)

        render json: { token: token, usuario: user, rotas: rots }, status: 200
      rescue => e
        render json: { error: e.message }, status: 500
      end
    end

    private

    def decode_basic_auth
      auth = request.headers["Authorization"]
      return [ "", "" ] unless auth&.start_with?("Basic ")
      decoded = Base64.decode64(auth.split(" ")[1])
      decoded.split(":", 2)
    end

    def jwt_token(user)
      payload = {
        _id: user._id,
        nome: user.nome,
        perfil: user.perfil,
        nivel: user.nivel,
        status: user.status,
        venda: user.venda,
        exp: 12.hours.from_now.to_i
      }
      JWT.encode(payload, jwt_secret, "HS256")
    end

    def jwt_secret
      ENV["SERV_KEYS"] || "chave_secreta_de_teste"
    end

    def on_auth_nome(name)
      db = MongoClient.use("acesso").database
      coll = db.collection("usuarios")
      docs = [
        { "$match" => { "nome" => name } },
        { "$lookup" => { "from" => "rotas", "localField" => "perfil", "foreignField" => "nome", "as" => "rota" } },
        { "$unwind" => { "path" => "$rota", "preserveNullAndEmptyArrays" => true } },
        { "$project" => { _id: 1, nome: 1, senha: 1, perfil: 1, nivel: 1, status: 1, venda: 1, imagem: 1, rotas: "$rota.rotas" } }
      ]
      result = coll.aggregate(docs).first
      raise "Usuário não encontrado!" if result.nil?
      result
    end
  end
end
