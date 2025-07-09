# app/services/realtime_fdb_runner.rb
require "open3"

class RealtimeFdbRunner
  def self.start
    Thread.new do
      python = RUBY_PLATFORM.include?("linux") ? "python3" : "python"
      command = "#{python} ../realtimeFdb.py"
      puts "📡 RealtimeFdb iniciado"

      Open3.popen3(command) do |_stdin, stdout, stderr, wait_thr|
        Thread.new do
          stdout.each do |line|
            realtime = line.strip
            next unless realtime&.start_with?("firebird/")

            puts "📡 Firebird evento recebido: #{line.strip}"
            ActionCable.server.broadcast("realtime", realtime)
          end
        end

        stderr.each { |line| Rails.logger.error "🔥 realtime stderr: #{line.strip}" }

        exit_status = wait_thr.value
        Rails.logger.info "📴 RealtimeFdb finalizado com status: #{exit_status}"
      end
    end
  end
end
