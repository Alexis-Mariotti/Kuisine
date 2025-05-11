# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # Invité (non connecté)

    # decline all permissions by default
    cannot :all, :all

    if user.admin?
      can :manage, :all
    #  verify if user exists in DB, so if is not a guest
    elsif user.persisted?
      # permissions for logged in users

      # recipe permissions
      can :create, Recipe
      can [ :update, :destroy ], Recipe, user_id: user.id
      # comment permissions
      can :create, Comment
      can [ :update, :destroy ], Comment do |comment|
        # user can only update or destroy his own comments
        comment.user_id == user.id
      end
      # can destroy comment on his own recipe
      can [ :destroy ], Comment do |comment|
        comment.recipe.user_id == user.id
      end
      # ingredient permissions
      can :create, Ingredient
      can [ :update, :destroy ], Ingredient do |ingredient|
        # user can only update or destroy his own ingredients
        ingredient.recipe.user_id == user.id
      end
      # user permissions
      can [ :update, :destroy, :read, :show ], User, id: user.id

    end

    # permissions for all users (including guests)

    # recipe permissions
    can [ :read, :show ], Recipe, is_public: true
    can [ :public, :create ], Recipe
    # comment permissions
    can [ :read, :show ], Comment
    # ingredient permissions
    can [ :read, :show ], Ingredient
    # user permissions
    can [ :read, :show, :create ], User
  end

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
end
