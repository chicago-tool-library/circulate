import "@hotwired/turbo-rails"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import "./controllers"

import "trix"
import "@rails/actiontext"

import { setupFeatherIcons } from "./lib/feather"

document.documentElement.addEventListener("turbo:load", setupFeatherIcons);
document.documentElement.addEventListener("turbo:frame-render", setupFeatherIcons);

// import scrollIntoView from 'smooth-scroll-into-view-if-needed';
// 
// Turbo.ScrollManager.prototype.scrollToElement = function(element) {
//   let classes = element.classList;
//   if (classes.contains("highlightable")) {
//     classes.add("highlight");
//   }
//   scrollIntoView(element, {
//     behavior: 'smooth',
//     scrollMode: 'if-needed',
//   });
// }
