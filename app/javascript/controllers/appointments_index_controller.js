import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "pending", "completed" ]

  connect() {
  }

  arrange() {
    Array.from(this.pendingTarget.querySelectorAll("tbody tr.completed")).forEach(element => {
      this.positionRow(element.parentElement, this.completedTarget);
    });
    Array.from(this.completedTarget.querySelectorAll("tbody tr.pending")).forEach(element => {
      this.positionRow(element.parentElement, this.pendingTarget);
    });
  }

  positionRow(element, parent) {
    const index = parseInt(element.dataset.index, 10);
    const found = Array.from(parent.children).some(sibling => {
      if (parseInt(sibling.dataset.index) > index) {
        parent.insertBefore(element, sibling)
        return true;
      }
    });

    if (!found) {
      parent.appendChild(element);
    }
  }
}
