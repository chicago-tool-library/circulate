import "@hotwired/turbo-rails"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import "./controllers"

import "trix"
import "@rails/actiontext"

import { setupFeatherIcons } from "./lib/feather"

document.documentElement.addEventListener("turbo:load", setupFeatherIcons);
document.documentElement.addEventListener("turbo:frame-render", setupFeatherIcons);
