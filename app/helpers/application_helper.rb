module ApplicationHelper

  def body_class(class_name)
    content_for :body_class, class_name
  end

  # user authentication methods

  # return the current logged user
  # return nil if no user is logged
  def current_user
    @current_user ||= User.where(id: session[:user_id]).first if session[:user_id]
  end

  # return true if a user is logged
  def logged_in?
    current_user.present?
  end

  # redirect to login page if no user is logged
  # WARNING this method is used as a before_action in controllers
  # Displays a flash message
  def require_login
    redirect_to login_path, alert: "Connectez-vous d'abord." unless logged_in?
  end

  # methode to display the login button or logout button
  def login_button
    if logged_in?
      button_to "Déconnexion", logout_path, method: :delete, class: "btn btn-danger"
    else
      link_to "Connexion", login_path, class: "btn btn-primary"
    end
  end

  def register_button
    if logged_in?
    else
      link_to "Inscription", signup_path, class: "btn btn-primary"
    end
  end


  # recommended to be used with sanitize
  def show_alert(type:, message:, icon:)
    tag.div(type:, class: 'alert alert-primary') do
      "#{tag.i(class:"bi bi-#{icon}" )}#{message}".html_safe
    end
  end
end
