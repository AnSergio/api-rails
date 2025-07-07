# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
    # Impede qualquer canal que não seja Realtime
    def self.inherited(subclass)
      super
      puts "🌐 subclass: #{subclass.name}"
      unless subclass.name == "Realtime"
        raise "Canal #{subclass.name} não autorizado"
      end
    end
    # def perform_action(data)
    # Impede qualquer frontend de enviar comandos
    #  reject_unauthorized_connection
    # end
  end
end
