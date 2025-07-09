# config/initializers/start_realtime.rb

Rails.application.config.after_initialize do
  RealtimeFdbRunner.start
  RealtimeMdbRunner.start
end
