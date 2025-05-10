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

  def is_admin?
    current_user&.admin?
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

  # method to display flash messages with shoelace
  def show_alert(type:, message:, icon:)
    tag.sl_alert(type:, open: true, closable: true, duration: '1500') do
      "#{tag.sl_icon(nil, slot: 'icon', name: icon)}#{message}".html_safe
    end
  end

  # link to public recepies list
  def public_recipes_link
    link_to "Recettes publiques", public_recipes_path, class: "btn btn-primary"
  end

  # link to user recipes list
  # Only if user is logged
  def recipes_index_link
    link_to "Mes recettes", recipes_path, class: "btn btn-primary" if logged_in?
  end

  # link to user profile page
  # Only if user is logged
  def profile_page_link
    link_to "Mon profil", user_path(current_user), class: "btn btn-primary" if logged_in?
  end

  # link to user profile edition page
  # Only if user is logged and admin
  def admin_users_link
    if logged_in? && current_user.admin?
      link_to "Gestion des utilisateurs", admin_users_path, class: "btn btn-primary"
    end
  end

end
