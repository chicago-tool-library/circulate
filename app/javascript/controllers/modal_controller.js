import { Controller } from "stimulus";


function isExternal(url) {
  const host = window.location.host;

  const link = document.createElement('a');
  link.href = url;
  return link.host !== host;
}


export default class extends Controller {
  static targets = [ "target", "modal" ]

  newWindow(event) {
    if (event.target.tagName ==="A") {
      const link = event.target;
      const url = link.getAttribute("href");

      if (isExternal(url)) {
        event.preventDefault();
        window.open(url, "_blank");
      }
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
