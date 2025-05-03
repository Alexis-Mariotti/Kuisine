import { Controller } from "@hotwired/stimulus"

// Stimulus controller to fetch ingredient suggestions from Open Food Facts
export default class extends Controller {
    static targets = ["input", "results"]

    connect() {
        this.resultsTarget.innerHTML = ""
    }

    search() {
        const query = this.inputTarget.value.trim()
        if (query.length < 3) {
            this.resultsTarget.innerHTML = ""
            return
        }

        fetch(`https://world.openfoodfacts.org/cgi/search.pl?search_terms=${encodeURIComponent(query)}&search_simple=1&action=process&json=1`)
            .then(response => response.json())
            .then(data => {
                const suggestions = data.products.slice(0, 5).map(p => p.product_name).filter(Boolean)
                this.resultsTarget.innerHTML = suggestions.map(name => `<li>${name}</li>`).join("")
            })
            .catch(err => {
                console.error("Erreur OpenFoodFacts:", err)
                this.resultsTarget.innerHTML = "<li>Erreur API</li>"
            })
    }
}
