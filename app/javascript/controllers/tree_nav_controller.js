import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    try {
      const location = window.location.href.toLowerCase()
      const url = new URL(location)
      const id = url.searchParams.get('category')

      if (!id) {
        return
      }

      let listItem = this.element.querySelector(`li.tree-node[data-id="${id}"]`)
      if (!listItem) {
        return
      }

      listItem.querySelector('a').classList.add('text-bold')
      while (listItem) {
        const button = listItem.querySelector('button')
        if (button) {
          this.toggleButton(button)
        }
        listItem = listItem.parentElement.closest('li.tree-node')
      }
    } catch (err) {
      console.error(err)
      // issue handling category id
    }
  }

  toggle(event) {
    const button = event.currentTarget
    this.toggleButton(button)
  }

  toggleButton(button) {
    if (button.getAttribute('aria-expanded') === 'true') {
      button.setAttribute('aria-expanded', 'false')
    } else {
      button.setAttribute('aria-expanded', 'true')
    }
    button.querySelector('i').classList.toggle('icon-arrow-right')
    button.querySelector('i').classList.toggle('icon-arrow-down')
  }
}
