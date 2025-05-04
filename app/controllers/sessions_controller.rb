class SessionsController < ApplicationController

  # login form
  def new
  end

  # login
  def create
    user = User.where(email: params[:email]).first
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id.to_s
      redirect_to root_path, notice: "Connecté"
    else
      flash.now[:alert] = "Email ou mot de passe incorrect"
      render :new
    end
  end

  # logout
  def destroy
    puts "destroy BBBB"
    session[:user_id] = nil
    redirect_to login_path, notice: "Déconnecté"
  end
end
