import "@hotwired/turbo-rails"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import "./controllers"

import "trix"
import "@rails/actiontext"

// When we send a custom turob action of "redirect", simply go to that location.
// Based on https://www.ducktypelabs.com/turbo-break-out-and-redirect/
Turbo.StreamActions.redirect = function () {
    Turbo.visit(this.target);
};

import { setupFeatherIcons } from "./lib/feather"

document.documentElement.addEventListener("turbo:load", setupFeatherIcons);
document.documentElement.addEventListener("turbo:frame-render", setupFeatherIcons);
