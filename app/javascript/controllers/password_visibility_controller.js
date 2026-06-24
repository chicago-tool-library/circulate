import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'button']

  toggle() {
    const isPassword = this.inputTarget.type === 'password'
    this.inputTarget.type = isPassword ? 'text' : 'password'
    this.buttonTarget.textContent = isPassword
      ? 'Hide password'
      : 'Show password'
    this.buttonTarget.setAttribute('aria-pressed', isPassword)
  }
}
