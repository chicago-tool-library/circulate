import { Application } from "@hotwired/stimulus"
import { appsignal } from "./../lib/appsignal"
import { installErrorHandler } from "@appsignal/stimulus"

const application = Application.start()
installErrorHandler(appsignal, application)

// Configure Stimulus development experience
application.warnings = true
application.debug = false
window.Stimulus   = application

export { application }
