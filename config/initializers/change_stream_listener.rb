# config/initializers/change_stream_listener.rb
require "thread"
require "mongo"
require "json"

Rails.application.config.after_initialize do
  Mongo::Logger.logger.level = ::Logger::INFO
  mongo_client = Mongo::Client.new(ENV["MONGODB_URI"], max_pool_size: 100)
  puts "📡 RaeltimeMongoDB}"
  ChangeStreamListener.new(mongo_client).start
end

class ChangeStreamListener
  EXCLUDED_DBS = %w[admin config local]

  def initialize(client)
    @client  = client
  end

  def start
    admin = @client.database.client.use("admin").database
    databases = admin.command(listDatabases: 1).first["databases"]

    databases.each do |db_info|
      db_name = db_info["name"]
      next if EXCLUDED_DBS.include?(db_name)

      db = @client.use(db_name).database
      db.collections.each do |collection|
        Thread.new do
          begin
            change_stream = collection.watch
            change_stream.each do |change|
              ns = change["ns"]
              next unless ns

              realtime = "#{ns["db"]}/#{ns["coll"]}"
              puts "📡 MongoDB: #{realtime}"
              ActionCable.server.broadcast("realtime", realtime)
            end
          rescue => e
            Rails.logger.error "Erro ao monitorar #{db_name}.#{collection.name}: #{e.message}"
          end
        end
      end
    end
  end
end




# ActionCable.server.broadcast("realtime",  topic)
