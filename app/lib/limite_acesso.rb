module Throttles
  class LimiteAcesso
    def self.apply
      Rack::Attack.throttle("req/ip", limit: 100, period: 1.minute) do |req|
        req.ip
      end
    end
  end
end
