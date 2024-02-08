import { Controller } from "@hotwired/stimulus";

const jquery = require("jquery");
const Selectize = require("@selectize/selectize");

export default class extends Controller {
  static targets = [ "input" ]

  connect() {
    this.selectize = jquery(this.inputTarget).selectize({
      copyClassesToDropdown: false,
      // create: true,
      plugins: ['remove_button'], // 'restore_on_backspace'
    });
  }

  load(query, callback) {
    let url = new URL(this.data.get("path"), document.location);
    fetch(url).then(response => response.json()).then((data) => {
      callback(data);
    }).catch((e) => {
      console.error(e);
    })
  }
}
