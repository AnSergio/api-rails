# /app/lib/throttle_acesso.rb
module Throttles
  class ThrottleAcesso
    def self.apply
      Rack::Attack.throttle("req/ip", limit: 100, period: 1.minute) do |req|
        req.ip
      end
    end
  end
end
