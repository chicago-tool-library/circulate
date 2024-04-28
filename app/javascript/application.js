import { Turbo } from '@hotwired/turbo-rails'
import * as ActiveStorage from '@rails/activestorage'
import 'trix'
import '@rails/actiontext'

import './controllers'
import { setupFeatherIcons } from './lib/feather'
import { arrangeAppointment } from './lib/appointments'

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
