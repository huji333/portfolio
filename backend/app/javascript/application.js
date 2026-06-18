// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"
import { Sortable } from "sortablejs"

ActiveStorage.start()

// Make Sortable available globally
window.Sortable = Sortable;
