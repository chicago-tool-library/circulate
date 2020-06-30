import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "target", "modal" ]

  newWindow(event) {
    if (event.target.tagName ==="A") {
      event.preventDefault();

      const link = event.target;
      const url = link.getAttribute("href");
      window.open(url, "_blank");
    }
  }

  hide(event) {
    if (event.keyCode === 27 || event.type === "click") {
      event.preventDefault();
      this.modalTarget.classList.remove("active");
    }
  }

  show(event) {
    event.preventDefault();
    this.modalTarget.classList.add("active");
  }
}
