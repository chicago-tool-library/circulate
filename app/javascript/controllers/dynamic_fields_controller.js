import { Controller } from "@hotwired/stimulus";

// This controller will create a clone of the template for use in forms
// where there is a button to add a new instance of an associated record.
export default class extends Controller {
  static targets = ["template"];

  add(event) {
    event.preventDefault();
    event.currentTarget.insertAdjacentHTML(
      "beforebegin",
      this.templateTarget.innerHTML.replace(
        /__CHILD_INDEX__/g,
        new Date().getTime().toString()
      )
    );
  }
}