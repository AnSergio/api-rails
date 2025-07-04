class AuthController < ApplicationController
  def login
    name, pass = decode_basic_auth(request)

  puts "🔐 Nome: #{name}, Senha: #{pass}"

  usuario = Usuario.where(nome: name).first
  puts "👤 Usuario encontrado: #{usuario.inspect}"

  if usuario.nil?
    puts "❌ Usuario não encontrado"
    return render json: { error: "Credenciais inválidas!" }, status: 401
  end

  senha_decodificada = decode_base64(usuario.senha)
  puts "🔓 Senha decodificada do banco: #{senha_decodificada}"

  if senha_decodificada != pass
    puts "❌ Senha incorreta"
    return render json: { error: "Credenciais inválidas!" }, status: 401
  end

  token = jwt_token(usuario.id.to_s, usuario.nome)
  puts "✅ Login com sucesso! Gerado token: #{token}"

    render json: {
      token: token,
      usuario: {
        _id: usuario.id.to_s,
        nome: usuario.nome,
        senha: senha_decodificada,
        perfil: usuario.perfil,
        nivel: usuario.nivel,
        status: usuario.status,
        venda: usuario.venda,
        imagem: usuario.imagem
      },
      rotas: usuario.rotas
    }, status: 200
  end

  private

  def decode_basic_auth(request)
    auth = request.headers['Authorization']
    return ["", ""] unless auth&.start_with?("Basic ")

    base64 = auth.split(" ")[1]
    decoded = Base64.decode64(base64)
    name, pass = decoded.split(":", 2)
    [name, pass]
  end

  def decode_base64(str)
    Base64.decode64(str || "")
  rescue
    ""
  end

  def jwt_token(user_id, nome)
    payload = { _id: user_id, nome: nome, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, jwt_secret, 'HS256')
  end

  def jwt_secret
    ENV['JWT_SECRET'] || 'chave_secreta_de_teste'
  end
end
