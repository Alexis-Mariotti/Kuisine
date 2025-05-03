class RecipesController < ApplicationController
  before_action :require_login, except: %i[show public]

  before_action :set_recipe, only: %i[show edit update destroy]
  before_action :authorize_user_owner, only: %i[edit update destroy show]

  # page to display all recipes
  def index
    @recipes = current_user.recipes
  end

  # page to display a recipe
  def show
  end

  # page to create a new recipe
  def new
    @recipe = current_user.recipes.new
    @error_messages = []
  end

  # action to create a new recipe
  def create
    @recipe = current_user.recipes.new(recipe_params)
    add_visibility # verify if the recipe is public or private

    # check if the form is correctly filled
    if recipe_validation
      if @recipe.save
        redirect_to @recipe, notice: "Recette créée avec succès."
      else
        render :new
      end
    end
  end

  # page to edit a recipe
  def edit
    @error_messages = []
  end

  # action for deleting a recipe
  def destroy
    @recipe.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to recipes_path, notice: "Recette supprimée" }
    end
  end

  # action for updating a recipe
  def update
    # check if the form is correctly filled
    if recipe_validation
      add_visibility # verify if the recipe is public or private
      if @recipe.update(recipe_params)
        respond_to do |format|
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@recipe, partial: "form", locals: { recipe: @recipe}) }
        end
      end
    end
  end

  # method to visualise all public recipes
  def public
    @string_research = params[:research]
    if @string_research.present?
      @recipes = Recipe.public_recipes_regex(@string_research)
    else
      @recipes = Recipe.public_recipes
    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end


  private

  def recipe_params
    params.require(:recipe).permit(:title, :ingredients, :instructions, :id_public)
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def authorize_user_owner
    # check if the recipe belongs to the current user
    # if not, redirect to the recipes page with an alert message

    # if the recipe is public, no need to check the owner
    unless @recipe.is_public
      if @recipe.user != current_user
        redirect_to recipes_path, alert: "Accès Non autorisé, vous n'êtes pas le propriétaire de la recette"
      end
    end
  end

  # verify if form is correctly filled
  def recipe_validation
    @error_messages = []
    if @recipe.title.blank?
      @error_messages << "Veuillez donner un titre à la recette, ça serait dommage de ne pas nomer une telle merveille"
    end

    if @recipe.ingredients.blank?
      @error_messages << "Aller, il faut bien des ingrédients pour faire une recette, non ?"
    end

    if @recipe.instructions.blank?
      @error_messages << "Bon, j'ai bien compris ce qu'on doit y mettre mais je ne sais pas comment aranger tout ça, il faut des instructions ! :)"''
    end

    if @error_messages.any?
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("new_recipe", partial: "form", locals: { recipe: @recipe }) }
      end
      # if there are errors, render the form with error error_messages and return false
      return false
    end
    # if no errors, return true
    true
  end

  def add_visibility
    @recipe.is_public = params[:recipe][:is_public]
  end
end
