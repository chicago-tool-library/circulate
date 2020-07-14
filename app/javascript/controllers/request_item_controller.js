import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
  }

  toggleLoader(show) {
    if (show) {
      this.loaderTarget.classList.remove("d-none");
    } else {
      this.loaderTarget.classList.add("d-none");
    }
  }

  undo(event) {
    this.submit("DELETE")
  }

  request(event) {
    this.submit("POST")
  }

  // Send data to server
  submit(method) {
    const itemID = this.data.get("id");
    
    let url = new URL("/holds/items", document.location);
    if (method ==="POST") {
      url.searchParams.set("item_id", itemID);
    } else if (method === "DELETE") {
      url.pathname += `/${itemID}`;
    }

    // this.toggleLoader(true);
    
    const token = document.querySelector("meta[name=csrf-token]").content;

    fetch(url, {
      method: method,
      headers: { "X-CSRF-Token": token }
    }).then(response => response.text()).then((html) => {
      const div = document.createElement("div");

      div.innerHTML = html;

      const newCart = div.querySelector("#cart");
      document.getElementById("cart").replaceWith(newCart);

      const newCard = div.querySelector(".tool-card");
      this.element.querySelector(".tool-card").replaceWith(newCard);

      document.dispatchEvent(new Event("turbolinks:load"));
    }).catch((e) => {
      // this.toggleLoader(false);
      console.error(e);
    })
  }
}