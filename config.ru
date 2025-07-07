# config.ru
require_relative "config/environment"

# require_relative "./app/services/change_stream_service"
# ChangeStreamService.new().start

run Rails.application
