import { Application } from "@hotwired/stimulus"
import { appsignal } from "./../lib/appsignal"
import { installErrorHandler } from "@appsignal/stimulus"

const application = Application.start()
installErrorHandler(appsignal, application)

// Send an error to AppSignal when a turbo fetch fails
window.addEventListener("turbo:fetch-request-error", (event) => {
    appsignal.sendError(event.detail.error, (span) => {
        const target = event.target.cloneNode(false)
        span.setAction("turbo:fetch-request-error")
        span.setNamespace("turbo")
        span.setParams({
            request_url: event.detail.request.url.toString(),
            target: target.outerHTML,
            submitter: event.detail.request.delegate.submitter.outerHTML,
        })
    })
})

// Configure Stimulus development experience
application.warnings = true
application.debug = false
window.Stimulus   = application

export { application }
