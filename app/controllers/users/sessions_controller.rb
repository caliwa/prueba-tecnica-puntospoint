# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionFix
  rate_limit to: 10, within: 30.seconds, with: -> { render json: { error: "Demasiadas peticiones" }, status: 429 }, store: cache_store
  respond_to :json
  # before_action :authorize_admin!

  # private
  # def authorize_admin!
  #   unless current_user.is_a?(Admin)
  #     render json: {
  #       error: "Solo administradores pueden acceder",
  #       status: 401
  #     }, status: :unauthorized and return
  #   end
  # end

  private

  def respond_with(resource, _opts = {}) #
    render json: {
      status: {
        code: 200,
        message: "Logueado exitosamente"
      },
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: "Deslogueado exitosamente"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "No se pudo encontrar una sesión activa."
      }, status: :unauthorized
    end
  end
end
