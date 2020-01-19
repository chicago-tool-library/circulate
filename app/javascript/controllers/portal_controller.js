import { Controller } from "stimulus"

export default class extends Controller {
  replaceContent(event) {
    let [ doc, message, xhr ] = event.detail;
    if (xhr.getResponseHeader("Content-Type").indexOf("text/html") === -1) {
      // This isn't an HTML response, so don't attempt to do anything clever.
      // Form submissions often return text/javascript that is evaled, for example.
      return;
    }

    while (this.element.firstChild) {
      this.element.removeChild(this.element.firstChild);
    }
    while (doc.body.firstChild) {
      this.element.appendChild(doc.body.firstChild);
    }
    this.installNoCacheMetaTag();
  }

  installNoCacheMetaTag() {
    let metaTag = document.querySelector("[name=turbolinks-cache-control]");

    if (!metaTag) {
      let meta = document.createElement("meta");
      meta.setAttribute("name", "turbolinks-cache-control");
      meta.setAttribute("content", "no-cache");
      document.head.appendChild(meta);

    } else if (metaTag.getAttribute("content") !== "no-cache") {
      meta.setAttribute("content", "no-cache");
    }
  }
}
