# frozen_string_literal: true

# class used to represent news articles
class News
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title,       type: String
  field :content,     type: String
  field :public,      type: Boolean, default: false
  # Field to inform if the news is distributed via a newsletter or not
  field :distributed, type: Boolean, default: false

  # The news can be send by email to the users by newsletter
  has_and_belongs_to_many :distribution_lists

  # the title and the content are required
  validates :title, :content, presence: true

  # Method wich provide all the news which are accessible by the user
  # The public + the news which are in the distribution list of the user
  # @param user [User] the user to check the access
  def self.accessible_by(user)
    # if the user is nul, return only the public news
    return where(public: true) unless user

    public_news = where(public: true)
    private_news = News.in(distribution_list_ids:  (defined? user.distribution_list_ids) ? user.distribution_list_ids : [])

    # return the news which are public or in the distribution list of the user
    public_news.or(private_news.selector)
  end

  # method to send the news via mail to all asigned distribution lists
  def send_to_distribution_list
    # send the newsletter to all the users in the distribution list
    distribution_lists.each do |list|
      list.users.each do |user|
        UserMailer.newsletter(self, user).deliver_now
      end
    end
  end
end
