module UsersHelper

  def display_form_errors(messages)
    # add an empty turbo frame if there are no errors
    if !(defined? messages) || messages.nil? || messages.empty?
      return turbo_frame_tag "error_messages"
    end
    html_message = "<turbo-frame id=\"error_messages\"><ul>"
    messages.each do |message|
      html_message += "<li>#{message}</li>"
    end
    html_message += "</ul></turbo-frame>"
    html_message.html_safe
  end
end
