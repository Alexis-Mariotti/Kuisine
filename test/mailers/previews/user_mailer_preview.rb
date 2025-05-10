# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def account_deleted
    # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_deleted
    user = User.first
    UserMailer.account_deleted(user)
  end
end
