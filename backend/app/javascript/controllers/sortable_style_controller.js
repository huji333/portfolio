import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.addStyles()
  }

  addStyles() {
    const style = document.createElement('style')
    style.textContent = `
      .handle {
        cursor: move;
        user-select: none;
      }
      .handle .material-symbols-outlined {
        vertical-align: middle;
        color: #999;
      }
      tr.sortable-ghost {
        opacity: 0.4;
        background: #f8f9fa;
      }
    `
    document.head.appendChild(style)
  }
}
