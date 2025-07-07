# config/initializers/rack_attack.rb
require Rails.root.join("app/lib/throttle_acesso")
require Rails.root.join("app/lib/throttle_login")

class Rack::Attack
  Throttles::ThrottleAcesso.apply
  Throttles::ThrottleLogin.apply

  Rack::Attack.throttled_responder = lambda do |request|
    now = Time.now.utc
    matched = request.env["rack.attack.matched"]
    # puts "matched: #{request}"

    message = case matched
    when "logins/ip"
      "Muitas tentativas de login. Tente novamente mais tarde."
    when "req/ip"
      "Muitos acessos. Por favor, aguarde antes de tentar novamente."
    else
      "Muitas requisições. Aguarde um instante."
    end

    [ 429, { "Content-Type" => "application/json" }, [ { error: message, time: now }.to_json ] ]
  end
end

# throttled_response eve
# throttled_responder request
