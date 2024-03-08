import { Controller } from "@hotwired/stimulus"

// This controller will toggle the visibility of the child target based on 
// a value from the parent target. By default, the value property of the parent
// target will be used, but this can be overriddeen using accessorValue.
export default class extends Controller {
  static targets = [ "parent", "child" ]
  static values = {
    accessor: String,
    trigger: String,
  }

  connect() {
    this.change();
  }

  change() {
    let accessor = !this.accessorValue ? "value" : this.accessorValue;
    let value = String(this.parentTarget[accessor]);
    let triggers = this.triggerValue.split(",");
    let displayValue = triggers.includes(value) ? "block" : "none";
    this.childTarget.style.display = displayValue;
  }
}
