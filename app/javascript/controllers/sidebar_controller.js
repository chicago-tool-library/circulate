import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['menu']

  open(event) {
    event.preventDefault()
    this.menuTarget.classList.add('active')
  }

  close(event) {
    event.preventDefault()
    this.menuTarget.classList.remove('active')
  }

  handleCache = () => {
    this.menuTarget.classList.remove('active')
  }

  connect() {
    document.addEventListener('turbo:before-cache', this.handleCache)
  }

  disconnect() {
    document.removeEventListener('turbo:before-cache', this.handleCache)
  }
}
