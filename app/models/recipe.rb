class Recipe
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :instructions, type: String
  field :is_public, type: Boolean, default: false
  # field to store the date of all views of the recipe
  # Only the public recipes are counted
  field :views, type: Array, default: []

  # associations

  has_many :comments, dependent: :destroy
  # recipe are written by users
  belongs_to :user
  # recipes have ingredient which have a specific model
  embeds_many :ingredients
  # accepts nested attributes for facilitate the creation of ingredients
  accepts_nested_attributes_for :ingredients, allow_destroy: true

  # return the total number of views of the recipe
  def total_views
    views.count
  end

  # method to get all public recipes
  def self.public_recipes
    Recipe.where(is_public: true)
  end

  # method to get all public recipes with a specific title
  def self.public_recipes_regex(title)
    Recipe.where(is_public: true, title: /#{Regexp.escape(title)}/i)
  end


  # method to get the tendency of public recipes in a period
  def self.trending(start_time, end_time, max = 3)
    # filter the recipes from the most viewed to the least viewed in the period
    recipes = all.select do |recipe|
      # get the views in the period
      views_in_period = recipe.views.select { |view| view >= start_time && view <= end_time }
      views_in_period.any?
    end
    # sort the recipes by the number of views and return it, truncating to max
    recipes.sort_by { |recipe| -recipe.views.count { |view| view >= start_time && view <= end_time } }.first(max)

  end


end