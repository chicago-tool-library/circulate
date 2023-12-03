import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import { setupFeatherIcons } from "../lib/feather"
import { turboFetch } from "../lib/request"

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

    setupFeatherIcons();
  }

  end(event) {
    const id = event.item.dataset.holdId
    const index = event.newIndex;
    const previousItem = this.element.querySelector(`*[data-initial-index="${index}"]`);
    const position = previousItem.dataset.position;

    let url = this.data.get("url").replace(":id", id);

    turboFetch(url, 'PUT', { position: position })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html);
      });
  }
}