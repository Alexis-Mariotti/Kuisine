# This controller manages the password reset process.
# it allows the user to request a password reset link and update their password
class PasswordResetsController < ApplicationController
  before_action :set_user, only: %i[edit update]
  before_action :redirect_if_logged_in
  def new
  end

  def create
    # init the error and info messages array
    @error_messages = []
    @info_messages = []

    # get the user from the data base
    # The user is found by the email
    @user = User.where(email: params[:email]).first

    # if the user is found
    if @user
      # generate the token for password reset
      @user.generate_password_reset_token!
      # and send it by email
      UserMailer.password_reset(@user).deliver_now

      # inform the user that the email is sent
      @info_messages << "Email envoyé à #{@user.email}, vous y trouverez un lien pour réinitialiser votre mot de passe."

      respond_to do |format|
        # redirect with adapted turbo stream for turbo format
        format.turbo_stream { render "shared/info_messages" }
        format.html do
          redirect_to new_password_reset_path, notice: "Un e-mail de réinitialisation a été envoyé."
        end
      end
    else
      @error_messages << "Adresse email ne correspond pas à un compte"
      respond_to do |format|
        format.turbo_stream { render "shared/error_messages" }
        format.html do
          render :new
        end
      end
    end
  end

  def update
    unless password_validation
      # if the password is not valid, render the errors
      render_error_messages
      return
    end
    if @user.update(password_params)
      @user.update(reset_password_token: nil, reset_password_sent_at: nil)
      respond_to do |format|
        # redirect with adapted turbo stream for turbo format
        format.turbo_stream { render partial: "shared/redirect", locals: { url: login_path }, notice: "Mot de passe réinitialisé avec succès." }
        format.html do
          redirect_to login_path, notice: "Mot de passe réinitialisé avec succès."
        end
      end
    else
      render :edit
    end
  end

  def edit
    # verify the token is still valid
    if @user.nil? || @user.password_reset_expired?
      respond_to do |format|
        # redirect with adapted turbo stream for turbo format
        format.turbo_stream { render partial: "shared/redirect", locals: { url: new_password_reset_path }, alert: "Le lien a expiré ou est invalide." }
        format.html do
          redirect_to new_password_reset_path, alert: "Le lien a expiré ou est invalide."
        end
      end
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    @user = User.where(reset_password_token: params[:id]).first
  end

  # check if the password is valid for all the criteria
  # @return [Boolean] true if the password is valid, false otherwise
  def password_validation
    set_error_messages

    # keep the original length of the error messages array to detect if there are new errors
    error_messages_length = @error_messages.length

    # ussing value passed into params
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]

    # verify emptyness
    if password.blank? || password_confirmation.blank?
      @error_messages << "Le mot de passe ne peut pas être vide"
    else
      # verify other criteria only if the password is not empty

      if password != password_confirmation
        @error_messages << "Les mots de passe ne correspondent pas"
      end
      # verify length
      if password.length < 6
        @error_messages << "Le mot de passe doit faire au moins 6 caractères"
      end
      # verify special characters
      if password !~ /[!@#$%^&*()_+{}|:"<>?]/ # regex for special characters
        @error_messages << "Le mot de passe doit contenir au moins un caractère spécial"
      end
    end

    # if length changed, there is new errors
    if error_messages_length != @error_messages.length
      return false
    end
    # if no errors, return true
    true
  end

  # render the error messages
  # @param context_page [Symbol] the context page to render the error messages
  def render_error_messages
    # display the errors via turbo stream or html depending on the context
    if @error_messages.any?
      respond_to do |format|
        format.turbo_stream { render "shared/error_messages" }
        format.html do
          render :edit
        end
      end
      # if there are errors, render the form with error error_messages and return false
      return false
    end
    # if no errors, return true
    true
  end

  # set the error messages array if not already defined
  def set_error_messages
    unless defined? @error_messages
      @error_messages = []
    end
  end

  # redirect home if the user is already logged in
  def redirect_if_logged_in
    # ignore for admins
    if can? :manage, :all
      return
    end
    if current_user
      respond_to do |format|
        format.turbo_stream { render partial: "shared/redirect", locals: { url: root_path }, notice: "Vous êtes déjà connecté." }
        format.html { redirect_to root_path, notice: "Vous êtes déjà connecté." }
      end
    end
  end
end
