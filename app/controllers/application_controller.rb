class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern


  # method to add the logged user in @current_user variable
  def current_user
    @current_user ||= User.where(id: session[:user_id]).first if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Vous devez être connecté pour accéder à cette page."
    end
  end


end
