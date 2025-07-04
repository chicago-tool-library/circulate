import { Controller } from '@hotwired/stimulus'

const jquery = require('jquery')
require('@selectize/selectize')

export default class extends Controller {
  static targets = ['input']

  initialize() {
    //Allows users to add new tags based on data-create attribute.
    this.createEnabled = this.element.dataset.create === 'true'
  }

  connect() {
    this.selectize = jquery(this.inputTarget).selectize({
      copyClassesToDropdown: false,
      create: this.createEnabled,
      plugins: ['remove_button'], // 'restore_on_backspace'
    })
  }

  load(query, callback) {
    const url = new URL(this.data.get('path'), document.location)
    fetch(url)
      .then((response) => response.json())
      .then((data) => {
        callback(data)
      })
      .catch((e) => {
        console.error(e)
      })
  }
}
