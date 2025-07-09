# config/initializers/realtime_mdb.rb
require "open3"

Rails.application.config.after_initialize do
  Thread.new do
    python = RUBY_PLATFORM.include?("linux") ? "python3" : "python"
    command = "#{python} ../postevent.py"
    puts "📡 RaeltimeMdb"

    Open3.popen3(command) do |_stdin, stdout, stderr, wait_thr|
      Thread.new do
        stdout.each do |line|
          puts "📡 Firebird evento recebido: #{line.strip}"
          topic = line.strip

          next unless topic&.start_with?("firebird/")
          ActionCable.server.broadcast("realtime",  topic)
        end
      end

      stderr.each { |line| Rails.logger.error "🔥 postevent stderr: #{line.strip}" }

      exit_status = wait_thr.value

      Rails.logger.info "📴 postevent finalizado com status: #{exit_status}"
    end
  end
end
