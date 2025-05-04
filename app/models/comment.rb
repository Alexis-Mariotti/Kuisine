class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String


  # a comment is written by a user on a recipe
  belongs_to :user
  belongs_to :recipe

  validates :content, presence: true
end
