import { Controller } from '@hotwired/stimulus'

let LIST_NUMBER = 0

const nextListNumber = () => LIST_NUMBER++

export default class extends Controller {
  static targets = ['input']

  datalistId = `autocomplete-datalist-${nextListNumber()}`

  connect() {
    this.datalist = this.createDataList()
    this.inputTarget.after(this.datalist)
    this.inputTarget.setAttribute('list', this.datalistId)
  }

  input(event) {
    const query = event.target.value

    if (query.length < 1) return

    this.fetchData(query)
      .then((data) => {
        this.populateDatalist(data)
      })
      .catch((e) => {
        console.error(e)
      })
  }

  fetchData(query) {
    const url = new URL(this.data.get('path'), document.location)
    url.searchParams.set('q', query)
    return fetch(url).then((response) => response.json())
  }

  createDataList() {
    const datalist = document.createElement('datalist')
    datalist.id = this.datalistId
    return datalist
  }

  createOption({ value }) {
    const option = document.createElement('option')
    option.value = value
    return option
  }

  clearDatalist() {
    this.datalist.replaceChildren()
  }

  populateDatalist(data) {
    this.clearDatalist()
    data.forEach((value) => {
      const option = this.createOption({ value })
      this.datalist.appendChild(option)
    })
  }
}
