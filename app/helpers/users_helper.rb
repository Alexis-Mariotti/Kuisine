module UsersHelper

  def display_form_errors(messages)
    html_message = "<turbo-frame id=\"error_messages\"><ul>"
    messages.each do |message|
      html_message += "<li>#{message}</li>"
    end
    html_message += "</ul></turbo-frame>"
    html_message.html_safe
  end
end
