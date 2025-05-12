import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "results", "container"]

    searchLength = 5
    api_search_uri = window.origin + "/ingredients/search"

    // method called when the input field is changed
    // used to call the api search method handled by the server
    async search() {
        const query = this.inputTarget.value.trim()

        // if the input is empty, we clear the results
        if (query.length === 0) {
            // clear the sugestions fields from the api response
            this.inputTarget.value = ""
            this.resultsTarget.innerHTML = ""
            return
        }

        /* if you want to have a minimum length for the search, you can uncomment this
        if (query.length < 2) {
            this.resultsTarget.innerHTML = ""
            return
        }
        */

        // create a local variable to store the api_search_uri attribute for the fetch
        const api_search_uri = this.api_search_uri
        try {
            // fecth from window origin to avoid 404 issues
            const response = await fetch(`${api_search_uri}?search=${encodeURIComponent(query)}&searchLength=${encodeURIComponent(this.searchLength)}`)
            const data = await response.json()

            this.resultsTarget.innerHTML = data.map(item => `
            <li>
              <button type="button" class="btn" data-action="click->ingredient-search#add" data-name="${item.name}" data-image="${item.image}">
                <img src="https://img.spoonacular.com/ingredients_100x100/${item.image}" class="ingredient-image"/>                
                ${item.name}
              </button>
            </li>
          `).join("") // join the array of strings into a single string because innerHTML expects a string

            // if the response is empty, display a message
            if (data.length === 0) {
                this.resultsTarget.innerHTML = "<p>On ne connais pas ça :/</p>"
            }

        } catch (error) {
            console.error("Erreur appel spoonacualr:", error)
        }
    }

    // method called when the user clicks on a suggestion
    // used to add the ingredient to the recipe form
    add(event) {
        // we get the name from the api response
        const name = event.currentTarget.dataset.name
        const image = event.currentTarget.dataset.image
        // the index is used to create a unique id for the input field
        // we use Date.now() to get a unique number
        const index = Date.now()

        // building the html for the new ingredient field

        const div = document.createElement("div")
        div.classList.add("ingredient-field")
        div.setAttribute("data-ingredient-search-target", "ingredient")
        div.innerHTML = `
      <div class="ingredient">
          <img src="https://img.spoonacular.com/ingredients_100x100/${image}" class="ingredient-image"/>
          <input type="text" name="recipe[ingredients_attributes][${index}][name]" id="recipe_ingredients_attributes_${index}_name" value="${name}" />
      </div>
      <input type="hidden" name="recipe[ingredients_attributes][${index}][image]" value="${image}" />
      <button type="button" class="btn btn-secondary" data-action="click->ingredient-search#removeField">Supprimer</button>
    `
        this.containerTarget.appendChild(div)

        // clear the sugestions fields from the api response
        this.inputTarget.value = ""
        this.resultsTarget.innerHTML = ""
    }

    removeField(event) {
        const field = event.currentTarget.closest(".ingredient-field")
        // if we found a hidden field, that means we are removing an existing ingredient
        // so we need to set the value of this hidden field to True, for the backend to know we want to remove it
        // the field is a _destroy field
        const hiddenField = field.querySelector("input[type=hidden][name*='_destroy']")
        //console.log(hiddenField)
        if (hiddenField) {
            hiddenField.value = "true"
            // we hide the original field
            field.style.display = "none"
        } else {
            // if we don't have a hidden field, we just remove the field
            // this is a new ingredient, so we can just remove it
            field.remove();
        }
    }
}
