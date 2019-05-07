import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "menu" ]

  open(event) {
    event.preventDefault();
    this.menuTarget.classList.add("active");
  }

  close(event) {
    event.preventDefault();
    this.menuTarget.classList.remove("active");
  }

  handleCache = () => {
    this.menuTarget.classList.remove("active");
  }

  connect() {
    document.addEventListener('turbolinks:before-cache', this.handleCache);
  }

  disconnect() {
    document.removeEventListener('turbolinks:before-cache', this.handleCache);
  }
}