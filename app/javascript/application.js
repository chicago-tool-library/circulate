import Rails from "@rails/ujs"
Rails.start()

import Turbolinks from "turbolinks"
Turbolinks.start()

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import "./controllers"

import "trix"
import "@rails/actiontext"

import feather from "feather-icons/dist/feather"
document.addEventListener("turbolinks:load", function() {
  feather.replace({
    width: 20,
    height: 20,
    class: "feather-icon",
  });
})

import scrollIntoView from 'smooth-scroll-into-view-if-needed';

Turbolinks.ScrollManager.prototype.scrollToElement = function(element) {
  let classes = element.classList;
  if (classes.contains("highlightable")) {
    classes.add("highlight");
  }
  scrollIntoView(element, {
    behavior: 'smooth',
    scrollMode: 'if-needed',
  });
}