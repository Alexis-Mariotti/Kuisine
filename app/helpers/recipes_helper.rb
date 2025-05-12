module RecipesHelper
  def display_form_errors(messages)
    # add an empty turbo frame if there are no errors
    if !(defined? messages) || messages.nil? || messages.empty?
      return turbo_frame_tag "error_messages"
    end
    html_message = "<div class=\"error_messages\"><ul class=\"error_messages\">"
    messages.each do |message|
      html_message += "<li>#{message}</li>"
    end
    html_message += "</ul></div>"
    html_message.html_safe
  end

  def visibility_section(recipe)
    content_tag(:section, class: "visibility") do
      if recipe.is_public
        content_tag(:span, "Publique", class: "visibility-label") +
          content_tag(:span, "#{recipe.total_views} vues", class: "views-count")
      else
        content_tag(:span, "Privée", class: "visibility-label")
      end
    end
  end

  def spoonacular_img(ingredient, size = "100x100", class_name = "ingredient-image")
    tag.img src: "https://img.spoonacular.com/ingredients_#{size}/#{ingredient.image}", alt: ingredient.name, class: class_name
  end
end
