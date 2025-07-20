class HomeController < ApplicationController
  def index
    if params[:password].present?
      app_name = Rails.application.class.module_parent_name.downcase
      if params[:password] == app_name

        token = Rails.application.message_verifier("one_time_token").generate(Time.now, expires_in: 60.seconds)
        puts token
        redirect_to "/api-docs/index.html?access_token=#{token}"
      else
        @error_message = "Clave incorrecta. Intenta de nuevo."
        render :index
      end
    else
      render :index
    end
  end
end
