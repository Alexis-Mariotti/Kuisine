# frozen_string_literal: true

class DistributionList
  include Mongoid::Document

  field :name, type: String

  # Distribution list can be used to send email to users
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true
end
