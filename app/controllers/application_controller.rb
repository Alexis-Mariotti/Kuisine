class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # redirect to a special page if the user perform an action without the permission
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to unauthorized_path
  end

  # method to add the logged user in @current_user variable
  def current_user
    @current_user ||= User.where(id: session[:user_id]).first if session[:user_id]
  end

  # method to check if the user is identified or not
  def logged_in?
    current_user.present?
  end

  # method to redirect to the login page if no user is logged
  def require_login
    unless logged_in?
      respond_to do |format|
        # redirect with the correct format
        format.turbo_stream { render partial: "shared/redirect", locals: { url: login_path } }
        format.html do
          flash[:alert] = "Vous devez être connecté pour accéder à cette page."
          redirect_to login_path
        end
      end
    end
  end

  def unauthorized
    respond_to do |format|
      format.turbo_stream { render partial: "shared/redirect", locals: { url: root_path } }
      format.html { render "unauthorized" }
    end
  end
end
