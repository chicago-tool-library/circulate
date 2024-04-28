import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button', 'toggled']

  connect () {
    this.toggledTarget.classList.add('d-none')
    this.buttonTarget.classList.remove('d-none')
  }

  toggle (event) {
    event.preventDefault()
    this.toggledTarget.classList.toggle('d-none')
    this.buttonTarget.classList.toggle('d-none')
  }
}
