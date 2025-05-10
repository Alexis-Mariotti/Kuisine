class SessionsController < ApplicationController

  # login form
  def new
    @error_messages = []
  end

  # login
  def create
    @error_messages = []

    user = User.where(email: params[:email]).first
    if user && user.authenticate(params[:password])
      # add the user to the session variable
      session[:user_id] = user.id.to_s

      respond_to do |format|
        format.turbo_stream { render partial: "shared/redirect", locals: { url: root_path }, notice: "Connecté" }
        format.html {redirect_to root_path, notice: "Connecté"}
      end
    else
      # puts "YYYYY"
      # add the error message
      @error_messages << "Email ou mot de passe incorrect"
      # and display it
      respond_to do |format|
        format.turbo_stream { render "shared/error_messages", locals: { error_messages: ["Email ou mot de passe incorrect"] } }
        format.html do
          render :new
        end
      end
    end
  end

  # logout
  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Déconnecté"
  end
end
