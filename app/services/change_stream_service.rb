# app/services/change_stream_service.rb
require "thread"
require "mongo"
require "json"

class ChangeStreamService
  EXCLUDED_DBS = %w[admin config local]

  def initialize
    @mongodb = Mongo::Client.new(ENV["MONGODB_URI"])
    @mqtt = MqttClient.new
  end

  def start
    admin = @mongodb.database.client.use("admin").database
    databases = admin.command(listDatabases: 1).first["databases"]
    # puts "databases: #{databases}"

    Thread.new do
      databases.each do |db_info|
        db_name = db_info["name"]
        next if EXCLUDED_DBS.include?(db_name)
        puts "db_name: #{db_name}"

        db = @mongodb.use(db_name).database
        db.collections.each do |collection|
          begin
            change_stream = collection.watch
            change_stream.each do |change|
              puts "db: #{db_name} coll: #{collection.name}"
              topic = "realtime/#{db_name}/#{collection.name}"
              payload = "#{db_name}/#{collection.name}"
              @mqtt.publish(topic, payload)

              ActionCable.server.broadcast("realtime", {
                db: db_name,
                collection: collection.name,
                payload: "#{db_name}/#{collection.name}"
              })
            end
          rescue => e
            Rails.logger.error "Erro ao monitorar #{db_name}.#{collection.name}: #{e.message}"
          end
        end
      end
    end
  end
end

# puts "topic: #{topic}, payload: #{payload}"
