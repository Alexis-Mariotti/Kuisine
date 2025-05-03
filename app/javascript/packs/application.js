//import { Application } from "@hotwired/stimulus"

import "@hotwired/turbo-rails"
import "controllers/index"

import '../../assets/stylesheets/application.scss';
import { setBasePath, SlAlert } from '@shoelace-style/shoelace'

// ...

const rootUrl = document.currentScript.src.replace(/\/packs.*$/, '')

// Path to the assets folder (should be independent from the current script source path
// to work correctly in different environments)
setBasePath(rootUrl + '/packs/js/')
import '../stylesheets/application.scss'
import { defineCustomElements, setAssetPath } from '@shoelace-style/shoelace'

setAssetPath(document.currentScript.src)

// This will import all shoelace web components for convenience.
// Check out the webpack documentation below on selective imports.
// https://shoelace.style/getting-started/installation?id=using-webpack
defineCustomElements()
