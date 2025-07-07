# app/channels/realtime.rb
class Realtime < ApplicationCable::Channel
  def subscribed
    # Apenas aceita conexões válidas e ativas
    reject unless current_user&.status == true

    stream_from "realtime"
    Rails.logger.info "✅ Subscrito ao realtime: #{current_user.nome}"
  end

  def unsubscribed
    Rails.logger.info "❌ Desconectado do realtime: #{current_user&.nome}"
  end
end
