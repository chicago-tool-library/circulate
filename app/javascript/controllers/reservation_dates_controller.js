import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['startDate', 'endDate']

  connect() {
    this.setMinEndDate()
    this.startDateTarget.addEventListener(
      'change',
      this.setMinEndDate.bind(this)
    )
  }

  setMinEndDate() {
    if (this.startDateTarget.value) {
      const dayAfterStartDate = new Date(this.startDateTarget.value)
      dayAfterStartDate.setDate(dayAfterStartDate.getDate() + 1)
      const minEndDate = dayAfterStartDate.toISOString().split('T')[0]
      this.endDateTarget.min = minEndDate
    }
  }
}
