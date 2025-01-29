import { Controller } from '@hotwired/stimulus'

const COMPLETE_SUCCESS = 'complete-success'
const PARTIAL_SUCCESS = 'partial-success'
const ERROR = 'error'

export default class extends Controller {
  playSound(event)  {
    const { newStream } = event.detail

    if (newStream.target === 'reservation-loan-form') {
      const soundType = newStream.querySelector('template').dataset.soundType

      console.log({soundType})
    }


  }
}
