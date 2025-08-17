// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { Sortable } from "sortablejs"
import { EXIF } from "exif-js"

// Make Sortable available globally
window.Sortable = Sortable;

// Make EXIF available globally
window.EXIF = EXIF;
