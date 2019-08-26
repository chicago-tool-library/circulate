import { Controller } from "stimulus";

import Awesomplete from "awesomplete";

export default class extends Controller {
  static targets = [ "input" ]

  connect() {
    this.awesomplete = new Awesomplete(this.inputTarget, {
      minChars: 1,
    });
  }

  input(event) {
    let url = new URL(this.data.get("path"), document.location);
    url.searchParams.set("q", event.target.value);
    fetch(url).then(response => response.json()).then((data) => {
      this.awesomplete.list = data;
    }).catch((e) => {
      console.error(e);
    })
  }
}
