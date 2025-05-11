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
  def login_button(text = "Connexion", class_name = "btn btn-primary")
    if logged_in?
      button_to "Déconnexion", logout_path, method: :delete, class: "btn btn-primary"
    else
      link_to text, login_path, class: class_name
    end
  end

  def register_button(text = "Inscription", class_name = "btn btn-primary")
    if logged_in?
    else
      link_to text, signup_path, class: class_name
    end
  end

  # method to display flash messages with shoelace
  def show_alert(type:, message:, icon:)
    tag.sl_alert(type:, open: true, closable: true, duration: "1500") do
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

  # link to admin users page
  # Only if user is logged and admin
  def admin_users_link
    if logged_in? && current_user.admin?
      link_to "Gestion des utilisateurs", admin_users_path, class: "btn btn-primary"
    end
  end

  # link to the admin news page
  # Only if user is logged and admin
  def admin_news_link
    if logged_in? && current_user.admin?
      link_to "Gestion des news", admin_news_index_path, class: "btn btn-primary"
    end
  end

  # link to the admin news creation page
  # Only if user is logged and admin
  def admin_news_new_link
    if logged_in? && current_user.admin?
      link_to "Créer une news", new_admin_news_path, class: "btn btn-primary"
    end
  end

  # link to the admin news edition page
  # Only if user is logged and admin
  def admin_news_edit_link(news)
    if logged_in? && current_user.admin?
      link_to "Modifier", edit_admin_news_path(news), class: "btn btn-primary"
    end
  end

  # show news link
  def news_link(news, class_name = "btn btn-primary")
    link_to news.title, news_url(news), class: class_name
  end

  # news index link
  def news_index_link(text = "Actualités", class_name = "btn btn-primary")
    link_to text, news_index_path, class: class_name
  end

  # link to forgot password page
  # Only if user is not logged
  def forgot_password_link(text = "Mot de passe oublié ?", class_name = "btn btn-primary")
    link_to text, new_password_reset_path,  class: class_name
  end

  # method to display error messages in a turbo frame
  def display_form_errors(messages)
    # add an empty turbo frame if there are no errors
    if !(defined? messages) || messages.nil? || messages.empty?
      return turbo_frame_tag "error_messages"
    end
    html_message = "<turbo-frame id=\"error_messages\"><ul class=\"error_messages\">"
    messages.each do |message|
      html_message += "<li>#{message}</li>"
    end
    html_message += "</ul></turbo-frame>"
    html_message.html_safe
  end

  # method to display info messages into a turbo frame
  def display_info_messages(messages)
    # add an empty turbo frame if there are no errors
    if !(defined? messages) || messages.nil? || messages.empty?
      return turbo_frame_tag "info_messages"
    end
    html_message = "<turbo-frame id=\"info_messages\"><ul class=\"info_messages\">"
    messages.each do |message|
      html_message += "<li>#{message}</li>"
    end
    html_message += "</ul></turbo-frame>"
    html_message.html_safe
  end
end
