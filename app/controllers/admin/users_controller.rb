class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!
  authorize_resource class: "User"
  # setting the user for actions where it's needed
  before_action :set_user, only: %i[destroy]

  def index
    @users = User.all
  end

  def destroy
    # destroy the user
    @user.destroy
    redirect_to admin_users_path, notice: "L'utilisateur a été supprimé."
  end

  private

  def authenticate_admin!
    redirect_to root_path unless current_user&.admin?
  end

  def set_user
    @user = User.find(params[:id])
  end
end
