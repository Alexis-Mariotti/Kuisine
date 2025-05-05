# frozen_string_literal: true
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # Invité (non connecté)

    if user.admin?
      can :manage, :all
    elsif user.is_logged_in?
      # permissions for logged in users

      # recipe permissions
      can :create, Recipe
      can [:update, :destroy], Recipe, user_id: user.id
      # comment permissions
      can :create, Comment
      can [:update, :destroy], Comment do |comment|
        # user can only update or destroy his own comments
        comment.user_id == user.id
      end
      # can destroy comment on his own recipe
      can [:destroy], Comment do |comment|
        comment.recipe.user_id == user.id
      end
      # ingredient permissions
      can :create, Ingredient
      can [:update, :destroy], Ingredient do |ingredient|
        # user can only update or destroy his own ingredients
        ingredient.recipe.user_id == user.id
      end
      # user permissions
      can [:update, :destroy, :read], User, id: user.id

    else
      # recipe permissions
      can :read, Recipe, is_public: true
      # comment permissions
      can :read, Comment
      # ingredient permissions
      can :read, Ingredient
      # user permissions
      can [:read, :create], User
    end
  end

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
end
