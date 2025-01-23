import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['control', 'summary']

  connect() {
    this.change()
  }

  change() {
    const options = this.controlTarget.selectedOptions
    const names = Array.prototype.map
      .call(options, (option) => option.text)
      .join('\n')
    this.summaryTarget.textContent = names
  }
}
