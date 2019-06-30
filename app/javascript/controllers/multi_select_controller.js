import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "control", "summary" ]

  connect() {
    this.change();
  }

  change() {
    let options = this.controlTarget.selectedOptions;
    let names = Array.prototype.map.call(options, (option) => option.text).join("\n");
    this.summaryTarget.textContent = names;
  }
}
