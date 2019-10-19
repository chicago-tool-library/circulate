import { Controller } from "stimulus";

export default class extends Controller {
  static allowedKeys = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Tab", "ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown", "Enter", "Backspace", "Delete"]

  keydown(event) {
    if (this.constructor.allowedKeys.indexOf(event.key) === -1) {
      event.preventDefault();
    }
  }
}
