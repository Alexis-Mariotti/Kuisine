class IngredientsController < ApplicationController


  # This method is used to interogate the spoonacular API to get the ingredients
  def search_spoonacular_ingredients
    # check the search ingredient
    query = params[:search]
    # check the numer of ingredients ( the search length)
    number = params[:searchLength]
    # if the search is empty, return an empty array to display nothing
    return render json: [] unless query.present?

    # get the api key in the encrypted credentials
    api_key = Rails.application.credentials.spoonacular_api_key
    # create the url to get the ingredients
    url = URI("https://api.spoonacular.com/food/ingredients/autocomplete?query=#{query}&number=#{number}&apiKey=#{api_key}")

    # send the request to the API via a GET request
    response = Net::HTTP.get(url)

    # parse the response to get the ingredients
    results = JSON.parse(response)

    render json: results
  end

end