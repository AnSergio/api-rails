# app/services/mqtt_client.rb
require "mqtt"

class MqttClient
  def initialize
    @client = MQTT::Client.connect(
      host: "192.168.0.254",
      port: 1883,
      username: "realtime",
      password: "realtime",
    )
  end

  def subscribe(topic = "realtime/#")
    @client.get(topic) do |topic, payload|
      puts "✅ subscribe, topic: #{topic}, payload: #{payload}"
    end
  end

  def publish(topic, payload)
    @client.publish(topic, payload)
    puts "✅ publish, topic: #{topic}, payload: #{payload}"
  end
end
