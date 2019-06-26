import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "parent", "child" ]

  connect() {
    this.change();
  }

  change() {
    let value = this.parentTarget.value;
    let displayValue = value === this.data.get("trigger") ? "block" : "none";
    this.childTarget.style.display = displayValue;
  }
}
