import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['image', 'field']

  connect () {
    this.rotation = parseInt(this.data.get('rotation'), 10)
    if (isNaN(this.rotation)) {
      throw new Error('rotation attribute needs to be provided')
    }
    this.updateImageStyle()
  }

  left (event) {
    event.preventDefault()
    this.adjustRotation(-90)
    this.updateImageStyle()
    this.updateField()
  }

  right (event) {
    event.preventDefault()
    this.adjustRotation(90)
    this.updateImageStyle()
    this.updateField()
  }

  adjustRotation (degrees) {
    this.rotation += degrees
    if (this.rotation === 360) {
      this.rotation = 0
    } else if (this.rotation === -90) {
      this.rotation = 270
    }
  }

  updateImageStyle () {
    this.imageTarget.style.transform = `rotate(${this.rotation}deg)`
  }

  updateField () {
    this.fieldTarget.value = this.rotation
  }
}
