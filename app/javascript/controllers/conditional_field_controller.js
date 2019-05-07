import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "child" ]

  connect() {
    this.childTarget.style.display = "none"
  }

  change(event) {
    let value = event.target.value;
    let displayValue = value === this.data.get("trigger") ? "block" : "none";
    this.childTarget.style.display = displayValue;
  }
}
