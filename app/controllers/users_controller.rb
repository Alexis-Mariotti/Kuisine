# This controller handles user registration.
class UsersController < ApplicationController
  load_and_authorize_resource
  before_action :set_user, except: %i[new create]
  def new
    @error_messages = []
    @user = User.new
  end

  def create
    @error_messages = []
    @user = User.new(user_params)

    # validate all confirmation
    if all_validation

      # add the executions lists
      @user.edit_distribution_list_subscription("user_newsletter", params[:suscribe_newsletter?])

      if @user.save
        session[:user_id] = @user.id.to_s
        redirect_to root_path, notice: "Inscription réussie"
      else
        render :new
      end
    else
      # password validation failed
      # render is already called in the all_validation method
    end
  end

  # the user profil page
  def show
  end

  # the user profil edition page
  def edit
    # init the error messages array
    @error_messages = []
  end

  # action called when the user update his profil
  def update
    # verification if password is modified
    if params[:user][:password].present? || params[:user][:password_confirmation].present?
      # check if the password is valid
      unless password_validation
        # if the password is not valid, render the errors
        render_error_messages(:edit)
        return
      end
    else
      # if no password is provided, remove it from the params
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    # check general validations
    unless general_validation(@user.email)
      # if the general validation is not valid, render the errors
      render_error_messages(:edit)
      return
    end

    # update the executions lists
    @user.edit_distribution_list_subscription("user_newsletter", params[:suscribe_newsletter?])
    # delete the param
    params.delete(:suscribe_newsletter?)


    # when all validations are ok, update the user
    if @user.update(user_params)
      redirect_to @user, notice: "Votre compte a été mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # action called when the user delete his account
  def destroy
    @user.destroy
    reset_session if current_user == @user
    respond_to do |format|
      # redirect with adapted turbo stream for turbo format
      format.turbo_stream { render partial: "shared/redirect", locals: { url: root_path } }
      # redirect to the root path with a notice
      format.html do
        redirect_to root_path, notice: "Votre compte a été supprimé."
      end
    end
    # redirect_to root_path, notice: "Votre compte a été supprimé."
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username, :suscribe_newsletter?)
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


  # check if the email already exists
  # @param actual_email [String] the actual email of the user, used for update action (to ignore the email already used by the user himself)
  # @return [Boolean] true if the email already exists, false otherwise
  def general_validation(actual_email = nil)
    set_error_messages

    # keep the original length of the error messages array to detect if there are new errors
    error_messages_length = @error_messages.length

    # check email emptyness
    # only if actual_email is not defined
    if params[:user][:email].blank? && actual_email.nil?
      @error_messages << "L'email ne peut pas être vide"
    else
      # check if the email already exists
      # ignore when the email is the same as the actual one
      if User.where(email: params[:user][:email]).exists? && params[:user][:email] != actual_email
        @error_messages << "L'email est déjà utilisé"
      end
    end

    # username must be at least 3 characters long
    if params[:user][:username].nil? || (!params[:user][:username].nil? && params[:user][:username].length < 3)
      @error_messages << "Le nom d'utilisateur doit faire au moins 3 caractères"
    end

    if error_messages_length != @error_messages.length
      return false
    end
    # if no errors, return true
    true
  end

  # render the error messages
  # @param context_page [Symbol] the context page to render the error messages
  def render_error_messages(context_page = :new)
    # display the errors via turbo stream or html depending on the context
    if @error_messages.any?
      respond_to do |format|
        format.turbo_stream { render "shared/error_messages" }
        format.html do
          render context_page
        end
      end
      # if there are errors, render the form with error error_messages and return false
      return false
    end
    # if no errors, return true
    true
  end

  # check all validations for the user (create and update)
  # @param context_page [Symbol] the context page to render the error messages
  # @return [Boolean] true if all validations are ok, false otherwise
  def all_validation(context_page = :new)
    set_error_messages

    # check all params
    general_validation
    password_validation

    # render the error messages given by the previous validation
    render_error_messages(context_page)
  end

  # set the error messages array if not already defined
  def set_error_messages
    unless defined? @error_messages
      @error_messages = []
    end
  end
end
