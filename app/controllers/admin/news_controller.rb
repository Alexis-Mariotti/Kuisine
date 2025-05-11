class Admin::NewsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_news, only: [ :edit, :update, :destroy ]

  def new
    @news = News.new
  end

  def index
    # get all the news sorted by creation date
    @news = News.order(created_at: :desc)
  end


  def create
    @news = News.new(news_params)

    # init the error and info messages array
    @error_messages = []
    @info_messages = []

    unless news_validation
      # if the news is not valid, render the errors
      render_error_messages
      return
    end
    if @news.save
      if @news.distribution_lists.any?
        # Send email to all users in the distribution lists
        @news.send_to_distribution_list

        # make the news distributed
        @news.update(distributed: true)
      end
      # redirect to the news index page
      respond_to do |format|
        # redirect with adapted turbo stream for turbo format
        format.turbo_stream { render partial: "shared/redirect", locals: { url: admin_news_index_path }, notice: "News créée avec succès." }
        format.html { redirect_to admin_news_index_path, notice: "News créée avec succès." }
      end
    else
      render :new
    end
  end

  def edit; end

  def update
    # init the error and info messages array
    @error_messages = []
    @info_messages = []

    unless news_validation
      # if the news is not valid, render the errors
      render_error_messages(:edit)
      return
    end

    if @news.update(news_params)
      # redirect to the news index page
      respond_to do |format|
        # redirect with adapted turbo stream for turbo format
        format.turbo_stream { render partial: "shared/redirect", locals: { url: admin_news_index_path }, notice: "News mise à jour avec succès." }
        format.html { redirect_to admin_news_index_path, notice: "News mise à jour avec succès." }
      end
    else
      render :edit
    end
  end

  def destroy
    @news.destroy
    respond_to do |format|
      # redirect with adapted turbo stream for turbo format
      format.turbo_stream { render partial: "shared/redirect", locals: { url: admin_news_index_path }, notice: "News supprimée." }
      format.html { redirect_to admin_news_index_path, notice: "News supprimée." }
    end
  end

  private

  def set_news
    @news = News.find(params[:id])
  end

  def news_params
    params.require(:news).permit(:title, :content, :public, distribution_list_ids: [])
  end

  def authenticate_admin!
    # verify if the user have rights to manage the news
    unless can? :manage, News
      respond_to do |format|
        # redirect with adapted turbo stream for turbo format
        format.turbo_stream { render partial: "shared/redirect", locals: { url: root_path }, alert: "Vous n'avez pas accès à cette page." }
        format.html { redirect_to root_path, alert: "Vous n'avez pas accès à cette page." }
      end
    end
  end

  # method to verify if the form is correctly filled
  def news_validation
    # use directly the params to avoid errors with editing
    title = params[:news][:title]
    content = params[:news][:content]

    # check if the form is correctly filled
    if title.blank?
      @error_messages << "Le titre ne peut pas être vide."
    end

    if content.blank?
      @error_messages << "Le contenu ne peut pas être vide."
    end

    # return true if there are no errors, false otherwise
    if @error_messages.empty?
      true
    else
      false
    end
  end

  # render the error messages
  # @param context_page [Symbol] the context page to render the error messages
  def render_error_messages(context_page = :new)
    # display the errors via turbo stream or html depending on the context
    if @error_messages.any?
      respond_to do |format|
        format.turbo_stream { render "shared/error_messages" }
        format.html { render context_page }
      end
      # if there are errors, render the form with error error_messages and return false
      return false
    end
    # if no errors, return true
    true
  end
end
