import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['display', 'select']

  connect () {
    this.sync()
  }

  sync () {
    const value = this.selectTarget.value

    const option = this.element.querySelector(`option[value="${value}"]`)
    if (option) {
      const optionGroup = option.parentElement
      if (optionGroup && optionGroup.tagName === 'OPTGROUP') {
        this.displayTarget.innerHTML = ` on <strong>${optionGroup.label}</strong>`
        return
      }
    }
    this.displayTarget.innerText = ''
  }
}
