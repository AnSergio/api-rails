module Throttles
  class LimiteLogin
    def self.apply
      Rack::Attack.throttle("logins/ip", limit: 5, period: 5.minutes) do |req|
        req.path == "/auth/login" && req.post? ? req.ip : nil
      end
    end
  end
end
