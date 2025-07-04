Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "/auth/login", to: "auth#login"
end
