# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Definir host e porta via .env ou fallback
host = ENV["SERV_HOST"] || "0.0.0.0"
port = ENV["SERV_PORT"] || "3300"
puts "tcp://#{host}:#{port}"

bind "tcp://#{host}:#{port}"
# bind "tcp://0.0.0.0:3300"

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Daemonize the server (uncomment to run as a daemon)
# daemonize true

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# plugin :tmp_restart
#
# pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
