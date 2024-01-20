import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "parent", "child" ]

  connect() {
    this.change();
  }

  change() {
    let value = this.parentTarget.value;
    let triggers = this.data.get("trigger").split(",");
    let displayValue = triggers.includes(value) ? "block" : "none";
    this.childTarget.style.display = displayValue;
  }
}
