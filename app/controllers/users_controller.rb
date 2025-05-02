# This controller handles user registration.
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

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
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def password_validation
    if @user.password != @user.password_confirmation
      flash.now[:alert] = "Les mots de passe ne correspondent pas"
      render :new
      return false
    end
    # verify length
    if @user.password.length < 6
      flash.now[:alert] = "Le mot de passe doit faire au moins 6 caractères"
      render :new
      return false
    end
    # verify special characters
    if @user.password !~ /[!@#$%^&*()_+{}|:"<>?]/ # regex for special characters
      flash.now[:alert] = "Le mot de passe doit contenir au moins un caractère spécial"
      render :new
      return false
    end
    true
  end
end
