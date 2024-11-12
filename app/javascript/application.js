import { Turbo } from '@hotwired/turbo-rails'
import * as ActiveStorage from '@rails/activestorage'
import 'trix'
import '@rails/actiontext'

import './controllers'
import { setupFeatherIcons } from './lib/feather'
import { arrangeAppointment } from './lib/appointments'
import { highlightElement } from './lib/highlight'

ActiveStorage.start()

// When we send a custom turob action of "redirect", simply go to that location.
// Based on https://www.ducktypelabs.com/turbo-break-out-and-redirect/
Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target)
}

Turbo.StreamActions.arrangeAppointment = function () {
  arrangeAppointment(this.target)
}

document.documentElement.addEventListener('turbo:load', setupFeatherIcons)
document.documentElement.addEventListener('turbo:frame-render', setupFeatherIcons)
document.documentElement.addEventListener('turbo:load', highlightElement)
document.documentElement.addEventListener('turbo:frame-render', highlightElement)

// Uncomment for trubo debugging sessions :-/
// const events = [
//   "turbo:fetch-request-error",
//   "turbo:frame-missing",
//   "turbo:frame-load",
//   "turbo:frame-render",
//   "turbo:before-frame-render",
//   "turbo:load",
//   "turbo:render",
//   "turbo:before-stream-render",
//   "turbo:before-render",
//   "turbo:before-cache",
//   "turbo:submit-end",
//   "turbo:before-fetch-response",
//   "turbo:before-fetch-request",
//   "turbo:submit-start",
//   "turbo:visit",
//   "turbo:before-visit",
//   "turbo:click"
// ]

// events.forEach(e => {
//   addEventListener(e, (event) => {
//     console.log(e, event);
//   });
// });
