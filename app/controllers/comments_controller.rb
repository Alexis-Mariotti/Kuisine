class CommentsController < ApplicationController
  before_action :require_login, only: [:create, :destroy]
  before_action :set_recipe
  before_action :set_comment, only: [:destroy]
  before_action :set_user, except: [:create]
  before_action :authorize_destroy!, only: [:destroy]

  def create
    # the comment is written by the current user
    @comment = @recipe.comments.build(comment_params.merge(user: current_user))

    if @comment.content.blank?
      flash.now[:alert] = "Le commentaire ne peut pas être vide."
      respond_to do |format|
        # todo: add a turbo stream to display the error message
        format.turbo_stream
        format.html { redirect_to recipe_path(@recipe) }
      end
      return
    end

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        # redirect with html format to refresh the page
        format.html { redirect_to recipe_path(@recipe) }
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to recipe_path(@recipe) }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  # method to set the comment
  def set_comment
    @comment = @recipe.comments.find(params[:id])
  end

  # method to set the user who wrote the comment
  def set_user
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  # method to set the recipe where the comment is written
  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  # method to check if the current user have the right to delete the comment
  def authorize_destroy!
    unless current_user == @comment.user || current_user == @recipe.user
      head :unauthorized
    end
  end
end
