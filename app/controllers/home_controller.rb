# frozen_string_literal: true

class HomeController < ApplicationController
  allow_browser versions: :modern
  # disable CSRF protection for turbo
  skip_before_action :verify_authenticity_token

  layout "application"

  def index
    render "home/index"
  end

  def test_turbo
    name = params[:name]
    # we set the locals to pass the name to the partial
    render partial: "home/test_turbo", locals: { name: name }
  end

end
