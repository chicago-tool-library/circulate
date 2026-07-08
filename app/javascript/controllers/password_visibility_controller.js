import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'button', 'shownLabel', 'hiddenLabel']

  connect() {
    this.position()
  }

  // The button is centered on the input's own box rather than the whole
  // wrapper, since form builders (e.g. SpectreFormBuilder) can stack a
  // label/hint around the input inside this controller's element.
  position() {
    const wrapperRect = this.element.getBoundingClientRect()
    const inputRect = this.inputTarget.getBoundingClientRect()
    this.buttonTarget.style.top = `${inputRect.top - wrapperRect.top + inputRect.height / 2}px`
  }

  toggle() {
    const isPassword = this.inputTarget.type === 'password'
    this.inputTarget.type = isPassword ? 'text' : 'password'
    this.shownLabelTarget.classList.toggle('d-none')
    this.hiddenLabelTarget.classList.toggle('d-none')
    this.buttonTarget.setAttribute('aria-pressed', isPassword)
  }
}
