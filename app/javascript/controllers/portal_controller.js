import { Controller } from "stimulus"

export default class extends Controller {
  replaceContent(event) {
    let [ body, message, xhr ] = event.detail;
    this.element.innerHTML = body
  }
}
