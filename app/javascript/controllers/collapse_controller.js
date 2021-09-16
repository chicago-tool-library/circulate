import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "content", "button" ]

  connect() {
    this.toggle();
  }

  toggle() {
    if (this.contentTarget.classList.contains("hidden")) {
      this.buttonTarget.setAttribute("aria-expanded", "true")
    } else {
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }
    this.contentTarget.classList.toggle("hidden");
  }
}
