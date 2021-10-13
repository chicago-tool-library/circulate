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
    event.preventDefault();
    event.stopPropagation();
    this.submit("DELETE");
  }

  request(event) {
    event.preventDefault();
    event.stopPropagation();
    this.submit("POST");
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

    const crsfMeta = document.querySelector("meta[name=csrf-token]");
    const headers = crsfMeta ? { "X-CSRF-Token": crsfMeta.content } : {};

    fetch(url, {
      method: method,
      headers: headers
    }).then(response => response.text()).then((html) => {
      const div = document.createElement("div");

      div.innerHTML = html;

      const newCart = div.querySelector("#cart");
      document.getElementById("cart").replaceWith(newCart);

      const newContinue = div.querySelector("#continue-button");
      document.getElementById("continue-button").replaceWith(newContinue);

      const newCard = div.querySelector(".tool-card");
      const existingCard = document.querySelector(`div[data-request-item-id='${itemID}'] .tool-card`);

      if (existingCard) {
        existingCard.replaceWith(newCard);
      }
      document.dispatchEvent(new Event("turbo:load"));
    }).catch((e) => {
      // this.toggleLoader(false);
      console.error(e);
    })
  }
}