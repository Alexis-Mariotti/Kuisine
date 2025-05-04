# a model for recipe ingredients
class Ingredient
  include Mongoid::Document

  field :name, type: String

  # a recipe can have many ingredients
  embedded_in :recipe

end
