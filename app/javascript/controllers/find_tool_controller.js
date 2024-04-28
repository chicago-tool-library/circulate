import { Controller } from '@hotwired/stimulus'
import { debounce } from 'lodash'

export default class extends Controller {
  static targets = ['input', 'results', 'loader']

  initialize () {
    this.load = debounce(this.load, 300)
  }

  loadResults (event) {
    if (this.queryIsValid()) {
      if (this.queryHasChanged()) {
        this.load()
      }
    } else {
      this.resultsTarget.innerHTML = ''
    }
  }

  queryIsValid () {
    return this.inputTarget.value.length > 2
  }

  queryHasChanged () {
    return this.inputTarget.value !== this.lastQuery
  }

  toggleLoader (show) {
    if (show) {
      this.loaderTarget.classList.remove('d-none')
    } else {
      this.loaderTarget.classList.add('d-none')
    }
  }

  load () {
    const query = this.inputTarget.value
    this.lastQuery = query

    const url = new URL('/holds/autocomplete', document.location)
    url.searchParams.set('query', query)

    this.toggleLoader(true)
    console.debug(this.inputTarget.value)

    fetch(url).then(response => response.text()).then((html) => {
      if (this.queryIsValid()) {
        this.resultsTarget.innerHTML = html
      }
      this.toggleLoader(false)
      document.dispatchEvent(new Event('turbo:load'))
    }).catch((e) => {
      this.toggleLoader(false)
      console.error(e)
    })
  }
}
