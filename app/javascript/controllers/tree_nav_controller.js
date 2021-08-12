import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.element.querySelectorAll("button.tree-node-toggle").forEach(button => {
        button.setAttribute("aria-expanded", "false")
    })
  }

  toggle(event) {
    console.debug(event.currentTarget)
    const button = event.currentTarget;

    if (button.getAttribute("aria-expanded") === "true") {
        button.setAttribute("aria-expanded", "false")
    } else {
        button.setAttribute("aria-expanded", "true")
    }
    button.querySelector("i").classList.toggle("icon-arrow-right")
    button.querySelector("i").classList.toggle("icon-arrow-down")
  }
}
