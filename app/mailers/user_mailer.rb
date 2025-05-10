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
end
