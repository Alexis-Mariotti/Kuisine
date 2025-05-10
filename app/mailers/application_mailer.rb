class ApplicationMailer < ActionMailer::Base
  default from: "kusine@example.com"
  helper :application
  # include route helper because the mailer is not in the same namespace as the routes
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Rails.application.credentials.host || "localhost:3000"

  layout "mailer"
end
