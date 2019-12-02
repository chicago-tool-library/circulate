import { Controller } from "stimulus"

export default class extends Controller {
  replaceContent(event) {
    let [ body, message, xhr ] = event.detail;
    this.element.innerHTML = body;

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
