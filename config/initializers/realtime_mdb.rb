# config/initializers/realtime_mdb.rb
require "open3"

Rails.application.config.after_initialize do
  Thread.new do
    python = RUBY_PLATFORM.include?("linux") ? "python3" : "python"
    command = "#{python} ../realtimeMdb.py"
    puts "📡 RaeltimeMdb"

    Open3.popen3(command) do |_stdin, stdout, stderr, wait_thr|
      Thread.new do
        stdout.each do |line|
          puts "📡 MongoDB evento recebido: #{line.strip}"
          realtime = line.strip

          next unless !realtime&.start_with?("📡")
          ActionCable.server.broadcast("realtime",  realtime)
        end
      end

      stderr.each { |line| Rails.logger.error "🔥 realtime stderr: #{line.strip}" }

      exit_status = wait_thr.value

      Rails.logger.info "📴 realtime finalizado com status: #{exit_status}"
    end
  end
end
