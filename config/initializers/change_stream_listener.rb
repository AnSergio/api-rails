# config/initializers/change_stream_listener.rb
require "thread"
require "mongo"
require "json"

class ChangeStreamListener
  EXCLUDED_DBS = %w[admin config local]

  def initialize(client)
    @client  = client
    @thread  = nil
    @running = false
    @mutex   = Mutex.new
  end

  def start
    @mutex.synchronize do
      return if @running

      @running = true
      Thread.abort_on_exception = true

      @thread = Thread.new do
        Thread.current.name = "MongoChangeStreamListener" if Thread.current.respond_to?(:name=)
        listen_for_changes
      end

      Rails.logger.info "📡 ChangeStreamListener iniciado"
    end
  end

  def stop
    @mutex.synchronize do
      return unless @running

      @running = false
      @thread.kill if @thread&.alive?
      @thread = nil

      Rails.logger.info "🛑 ChangeStreamListener parado"
    end
  end

  private

  def listen_for_changes
    admin = @client.database.client.use("admin").database
    databases = admin.command(listDatabases: 1).first["databases"]
    puts "databases: #{databases}"

    databases.each do |db_info|
      db_name = db_info["name"]
      next if EXCLUDED_DBS.include?(db_name)
      puts "db_name: #{db_name}"

      db = @client.use(db_name).database
      db.collections.each do |collection|
        begin
          change_stream = collection.watch
          change_stream.each do |change|
            break unless @running  # permite encerrar loop externo
            realtime = "#{db_name}/#{collection.name}"
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

# Inicializa ao subir o Rails
Rails.application.config.after_initialize do
  mongo_client = Mongo::Client.new(ENV["MONGODB_URI"])
  $change_stream_listener = ChangeStreamListener.new(mongo_client)
  $change_stream_listener.start
end

# ActionCable.server.broadcast("realtime",  topic)
