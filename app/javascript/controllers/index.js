// Import and register all your controllers from the importmap via controllers/**/*_controller
import { Application } from "@hotwired/stimulus"


//import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
//eagerLoadControllersFrom("controllers", application)

//const controllers = import.meta.glob('./*_controller.js',{ eager: true })

//application.register(controllers)

import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

window.Stimulus = Application.start()
const context = require.context(".", true, /\.js$/)
Stimulus.load(definitionsFromContext(context))