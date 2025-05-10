require 'digest'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :password_salt, type: String # for the hash
  field :password_hash, type: String
  field :username, type: String

  # non obligatory fields
  field :reset_password_token, type: String, default: nil
  field :reset_password_sent_at, type: DateTime, default: nil
  field :role, type: String, default: nil

  #todo: add avatars

  # Associations
  has_many :recipes, dependent: :destroy
  has_many :comments, dependent: :destroy


  attr_accessor :password, :password_confirmation

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true, on: :create

  before_save :encrypt_password, if: :password_present?

  # Validates the password against the stored hash
  # @param submitted_password [String] The password to validate
  # @return [Boolean] True if the password is valid, false otherwise
  def authenticate(submitted_password)
    Digest::SHA256.hexdigest(password_salt + submitted_password) == password_hash
  end

  # Checks if the user is an admin
  # @return [Boolean] True if the user is an admin, false otherwise
  def admin?
    # at this time the role is defined manually and it's work because we use nosql database
    (defined? role) && role == "admin"
  end

  def destroy
    # remove all the recipes and comments of the user
    # recipes.destroy_all
    # comments.destroy_all

    # send a mail to the user email, to inform him that his account has been deleted
    UserMailer.account_deleted(self).deliver_now
    super
  end

  # forgotten password methods

  # Generates a password reset token and sets the sent time
  def generate_password_reset_token!
    # generate a random token for the reset password procedure
    self.reset_password_token = SecureRandom.urlsafe_base64
    # set the time of the token generation, for the expiration
    self.reset_password_sent_at = Time.now
    save!
  end

  # Checks if the password reset token is valid
  def password_reset_expired?
    # define the validity period for the token
    reset_token_validity = 2.hours # TODO: move to config

    # check if the token is expired
    reset_password_sent_at < reset_token_validity.ago
  end

  # end of forgotten password methods

  private

  # Encrypts the password using SHA256 and a random salt
  def encrypt_password
    self.password_salt = SecureRandom.hex(16)
    self.password_hash = Digest::SHA256.hexdigest(password_salt + password)
  end

  # Checks if the password is present
  def password_present?
    !password.nil?
  end
end

