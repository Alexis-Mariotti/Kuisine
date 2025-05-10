class ApplicationMailer < ActionMailer::Base
  default from: "kusine@example.com"
  helper :application
  layout "mailer"

  # set the default url options for the mailer
  def default_url_options
    # identify the correct host
    { host: Rails.application.credentials.host || "localhost:3000",
      # https protocol to avoid the port in urls
      protocol: "https" }
  end
end
