class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_current_attributes

  private

  def set_current_attributes
    if user_signed_in?
      Current.user = current_user
      Current.request = request
    end
  end

  private

  def authorize_admin!
    return if current_user&.admin?

    render json: { error: "Acceso denegado. Se requiere rol de administrador." }, status: :forbidden
  end
end
