# app/lib/mongo_d_b.rb
class MongoDB
  def self.usuarios
    MongoClient.use("acesso").database["usuarios"]
  end

  def self.rotas
    MongoClient.use("acesso").database["rotas"]
  end
end
