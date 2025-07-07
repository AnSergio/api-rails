# config/routes.rb
Rails.application.routes.draw do
  # mount ActionCable.server => "/cable"

  namespace :auth do
    post :login, to: "login#login"
    post :user,  to: "user#user"
    post :users, to: "users#users"
  end
end

# post "/auth/login", to: "auth#login"
