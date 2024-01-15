import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form" ];

  toggleAvailable() {
    this.formTarget.submit();
  }
}
