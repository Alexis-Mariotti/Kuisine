import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    // cooldown time for searching on the search bar input
     cooldown_timeout = 200;

    // method to submit the form
    // to bind on the text_field of search bar
    search() {
        // reset the cooldown
        clearTimeout(this.cooldown)

        // setting cooldown
        this.cooldown = setTimeout(() => {
            this.element.requestSubmit()
        }, this.cooldown_timeout)
    }

    connect() {
        this.cooldown = null;
    }

    disconnect() {
    }
}
