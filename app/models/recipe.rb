class Recipe
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :ingredients, type: String
  field :instructions, type: String
  field :is_public, type: Boolean, default: false

  # recipe are written by users
  belongs_to :user


  # method to get all public recipes
  def self.public_recipes
    Recipe.where(is_public: true)
  end

  # method to get all public recipes with a specific title
  def self.public_recipes_regex(title)
    Recipe.where(is_public: true, title: /#{Regexp.escape(title)}/i)
  end
end