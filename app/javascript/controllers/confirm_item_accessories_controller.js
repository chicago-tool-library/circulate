import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['accessory', 'button']

  handleCheck() {
    const allChecked = this.accessoryTargets.every(
      (checkbox) => checkbox.checked
    )

    this.buttonTarget.disabled = !allChecked
  }
}
