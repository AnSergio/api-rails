# app/models/usuario.rb
class Usuario
  include Mongoid::Document

  field :nome, type: String
  field :senha, type: String
  field :perfil, type: String
  field :nivel, type: Integer
  field :status, type: String
  field :venda, type: Boolean
  field :imagem, type: String
  field :rotas, type: Array
end
