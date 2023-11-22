import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import { setupFeatherIcons } from "../lib/feather"

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

    this.token = document.querySelector(
      'meta[name="csrf-token"]'
    ).content;

    setupFeatherIcons();
  }

  end(event) {
    const id = event.item.dataset.holdId
    const index = event.newIndex;
    const previousItem = this.element.querySelector(`*[data-initial-index="${index}"]`);
    const position = previousItem.dataset.position;

    let url = this.data.get("url").replace(":id", id);

    fetch(url, {
      method: 'PUT',
      headers: {
        'X-CSRF-Token': this.token,
        'Content-Type': 'application/json',
        'Accept': "text/vnd.turbo-stream.html",
      },
      credentials: 'same-origin',
      body: JSON.stringify({
        position: position,
      })
    }).then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html);
    });
  }
}