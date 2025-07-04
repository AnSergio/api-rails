# config/initializers/rack_attack.rb
require Rails.root.join("app/lib/limite_acesso")
require Rails.root.join("app/lib/limite_login")

class Rack::Attack
  Throttles::LimiteAcesso.apply
  Throttles::LimiteLogin.apply

  Rack::Attack.throttled_response = lambda do |env|
    now = Time.now.utc
    matched = env["rack.attack.matched"]

    # puts "matched: #{matched}"

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
