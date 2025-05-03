module RecipesHelper

  def display_form_errors(messages)
    html_message = "<div class=\"error_messages\"><ul>";
    messages.each do |message|
      html_message += "<li>#{message}</li>"
    end
    html_message += "</ul></div>"
    html_message.html_safe
  end
end
