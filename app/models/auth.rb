class Auth
  attr_reader :token, :usuario, :rotas

  def initialize(attrs = {})
    @token   = attrs[:token]
    @usuario = attrs[:usuario]
    @rotas   = attrs[:rotas]
  end

  def self.from(result)
    new(
      token: result["token"],
      usuario: User.from(result["usuario"]),
      rotas: result["rotas"]
    )
  end

  def as_json(*)
    {
      token: token,
      usuario: usuario.as_json,
      rotas: rotas
    }
  end
end
