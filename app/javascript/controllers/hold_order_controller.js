import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [ "tbody" ]

  connect() {
    this.sortable = Sortable.create(this.tbodyTarget, {
      animation: 150,
      handle: ".drag-handle",
      filter: ".notified",
      onEnd: this.end.bind(this),
      onMove: (event) => {
        if (event.related.classList.contains('notified')) return false;
    },
      chosenClass: "sorting",
      ghostClass: "ghost",
    })
  }

  end(event) {
    const id = event.item.dataset.holdId
    const index = event.newIndex;
    const previousItem = this.element.querySelector(`*[data-initial-index="${index}"]`);
    const position = previousItem.dataset.position;

    let data = new FormData()
    data.append("position", position)

    Rails.ajax({
      url: this.data.get("url").replace(":id", id),
      type: 'PUT',
      data: data,
      success: (response, statusText, xhr) => {
        this.replaceHoldRows(response)
      }
    })
  }

  replaceHoldRows(response) {
    while (this.tbodyTarget.firstChild) {
      this.tbodyTarget.removeChild(this.tbodyTarget.firstChild);
    }

    // Table rows need to be wrapped in a table tag so the browser doesn't
    // discard some of the elements for being invalid. In that case, we
    // want to ignore that wrapper element.
    let source = response.body;
    while (source.firstElementChild.dataset.portalIgnore === "true") {
      source = source.firstElementChild;
    }

    while (source.firstChild) {
      this.tbodyTarget.appendChild(source.firstChild);
    }

    document.dispatchEvent(new Event("turbolinks:load"));
  }
}