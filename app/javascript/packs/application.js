import { Application } from "@hotwired/stimulus"

import "@hotwired/turbo-rails"
import "app/javascript/controllers"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

import "@shoelace-style/shoelace"
import '../stylesheets/application.scss'
import {  SlAlert } from '@shoelace-style/shoelace'



import "controllers"
