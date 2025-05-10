# the mailer used for sending mails about the users accounts
class UserMailer < ApplicationMailer


# mail send to the user email to inform him/her that his/her account has been deleted
  def account_deleted(user, deleted_at = Time.now)
    # set the user instance variable to use it in the mailer view
    @user = user
    @deleted_at = deleted_at
    # set the mailer view to use it in the mailer
    mail(to: @user.email, subject: "Votre compte Kuisine a été supprimé !")
  end

  # mail sent to the user email to give him/her the link to reset his/her password
  def password_reset(user)
    @user = user
    mail(to: @user.email, subject: "Réinitialisation de votre mot de passe")
  end

  # mail sent to the user email to inform him/her about a new publication
  def newsletter(news, user)
    # define the instance variables to use them in the mailer view
    @news = news
    @user = user
    mail to: user.email, subject: "Nouvelle publication : #{@news.title}"
  end

end
