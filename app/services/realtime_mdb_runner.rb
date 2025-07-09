# app/services/realtime_mdb_runner.rb
require "thread"
require "mongo"
require "json"

# Rails.application.config.after_initialize do
# Mongo::Logger.logger.level = ::Logger::INFO
# mongo_client = Mongo::Client.new(ENV["MONGODB_URI"], max_pool_size: 100)
# puts "📡 RaeltimeMongoDB}"
# ChangeStreamListener.new(mongo_client).start
# end

class RealtimeMdbRunner
  EXCLUDED_DBS = %w[admin config local]
  CLIENT  = Mongo::Client.new(ENV["MONGODB_URI"], max_pool_size: 100)

  def self.start
    puts "📡 RealtimeMdb iniciado"
    admin = CLIENT.database.client.use("admin").database
    databases = admin.command(listDatabases: 1).first["databases"]

    databases.each do |db_info|
      db_name = db_info["name"]
      next if EXCLUDED_DBS.include?(db_name)

      db = CLIENT.use(db_name).database
      db.collections.each do |collection|
        Thread.new do
          begin
            change_stream = collection.watch
            change_stream.each do |change|
              ns = change["ns"]
              next unless ns

              realtime = "#{ns["db"]}/#{ns["coll"]}"
              puts "📡 MongoDB evento recebido: #{realtime}"
              ActionCable.server.broadcast("realtime", realtime)
            end
          rescue => e
            Rails.logger.error "🔥 Erro ao monitorar #{db_name}.#{collection.name}: #{e.message}"
          end
        end
      end
    end
  end
end
