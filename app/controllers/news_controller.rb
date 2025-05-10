# frozen_string_literal: true

# This controller handles the news articles
class NewsController < ApplicationController

  # page to display all the visible news by the user
  def index
    # init the @news array with all the news that are accessible by the user
    @news = News.accessible_by(current_user).order(created_at: :desc)
  end

  # action to display a news article
  def show
    @news = News.find(params[:id])
    unless @news.public || current_user
      respond_to do |format|
        # redirect with adapted turbo stream for turbo format
        format.turbo_stream { render partial: "shared/redirect", locals: { url: news_index_path }, alert: "Vous devez être connecté pour voir cette news." }
        format.html { redirect_to news_index_path, alert: "Vous devez être connecté pour voir cette news." }
      end
    end
  end
end
