import { Controller } from "stimulus"

export default class extends Controller {
  remove() {
    this.element.remove();
  }
}