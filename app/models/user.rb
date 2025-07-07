class User
  attr_reader :_id, :nome, :senha, :perfil, :nivel, :status, :venda, :imagem

  def initialize(attrs = {})
    @_id     = attrs[:_id]
    @nome   = attrs[:nome]
    @senha  = attrs[:senha]
    @perfil = attrs[:perfil]
    @nivel  = attrs[:nivel]
    @status = attrs[:status]
    @venda  = attrs[:venda]
    @imagem = attrs[:imagem]
  end

  def self.from(result)
    new(
      _id: result["_id"].to_s,
      nome: result["nome"],
      senha: decode_base64(result["senha"]),
      perfil: result["perfil"],
      nivel: result["nivel"],
      status: result["status"],
      venda: result["venda"],
      imagem: result["imagem"]
    )
  end

  def self.str(result)
    new(
      _id: result["_id"],
      nome: result["nome"],
      senha: result["senha"],
      perfil: result["perfil"],
      nivel: result["nivel"],
      status: result["status"],
      venda: result["venda"],
      imagem: result["imagem"]
    )
  end

  def as_json(*)
  {
    _id: _id,
    nome: nome,
    senha: senha,
    perfil: perfil,
    nivel: nivel,
    status: status,
    venda: venda,
    imagem: imagem
  }
  end

  private

  def self.decode_base64(str)
    Base64.decode64(str || "")
  rescue
    ""
  end
end
