# This controller handles user registration.
class UsersController < ApplicationController
  load_and_authorize_resource
  def new
    @error_messages = []
    @user = User.new
  end

  def create
    @error_messages = []
    @user = User.new(user_params)

    # check if email already exists
    if User.where(email: @user.email).exists?
      flash.now[:alert] = "L'email est déjà utilisé"
      render :new
      return
    end

    # validate password confirmation
    if password_validation
      if @user.save
        session[:user_id] = @user.id.to_s
        redirect_to root_path, notice: "Inscription réussie"
      else
        render :new
      end
    else
      # password validation failed
      # render is already called in the password_validation method
    end


  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username)
  end

  def password_validation
    @error_messages = []

    if @user.password != @user.password_confirmation
      @error_messages << "Les mots de passe ne correspondent pas"
    end
    # verify length
    if @user.password.length < 6
      @error_messages << "Le mot de passe doit faire au moins 6 caractères"
    end
    # verify special characters
    if @user.password !~ /[!@#$%^&*()_+{}|:"<>?]/ # regex for special characters
      @error_messages << "Le mot de passe doit contenir au moins un caractère spécial"
    end
    puts "LOLOLO #{@user.username}"
    # username must be at least 3 characters long
    if @user.username.nil? || (!@user.username.nil? && @user.username.length < 3)
      @error_messages << "Le nom d'utilisateur doit faire au moins 3 caractères"
    end

    # display the errors via turbo stream
    if @error_messages.any?
      respond_to do |format|
        format.turbo_stream { render "shared/error_messages" }
        format.html do
          render :new
        end
      end
      # if there are errors, render the form with error error_messages and return false
      return false
    end
    # if no errors, return true
    true
  end
end
