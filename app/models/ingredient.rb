# a model for recipe ingredients
class Ingredient
  include Mongoid::Document

  field :name, type: String
  field :image, type: String, default: "apple.jpg"

  # a recipe can have many ingredients
  embedded_in :recipe
end
