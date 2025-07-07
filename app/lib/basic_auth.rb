# /app/lib/basic_auth.rb
module BasicAuth
  extend ActiveSupport::Concern

  included do
    before_action :authorize_basic
  end

  private

  def authorize_basic
    auth = request.headers["Authorization"]
    unless auth&.start_with?("Basic ")
      render json: { error: "Autenticação obrigatória!" }, status: 401 and return
    end
  end
end
