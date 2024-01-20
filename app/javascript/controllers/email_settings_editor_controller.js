import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "form", "preview" ]

  showMarquee(event) {
    const marqueeTarget = this.previewTarget.contentWindow.document.querySelector(`.${event.currentTarget.id}`);
    if (marqueeTarget) {
      marqueeTarget.classList.add("marquee");
    }
  }

  startEditing(event) {
    this.currentlyEditing = event.currentTarget;
  }

  stopEditing(event) {
    this.currentlyEditing = null;
  }

  hideMarquee(event) {
    const marqueeTarget = this.previewTarget.contentWindow.document.querySelector(`.${event.currentTarget.id}`);
    if (marqueeTarget) {
      marqueeTarget.classList.remove("marquee");
    }
  }

  update(event) {
    // This works for both input elements and trix editors.
    const div = this.previewTarget.contentWindow.document.querySelector(`.${event.currentTarget.id}`);
    if (div) {
      div.innerHTML = event.currentTarget.value;
    }
  }

  connect() {
  }
}