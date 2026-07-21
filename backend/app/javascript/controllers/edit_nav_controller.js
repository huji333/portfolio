import { Controller } from "@hotwired/stimulus"

// 編集フォームの ←/→ キーで前後の画像へ移動する。既存の nav_prev/nav_next submit
// ボタンを踏むため、保存してから移動する挙動もボタンと同一になる。
export default class extends Controller {
  static targets = ["prev", "next"]

  handleKeydown(event) {
    const target = event.target
    const isTextInput = /^(INPUT|SELECT|TEXTAREA)$/.test(target.tagName) && target.type !== "checkbox"
    if (isTextInput || event.metaKey || event.ctrlKey || event.altKey) return

    if (event.key === "ArrowLeft" && this.hasPrevTarget) {
      event.preventDefault()
      this.clickUnlessDisabled(this.prevTarget)
    } else if (event.key === "ArrowRight" && this.hasNextTarget) {
      event.preventDefault()
      this.clickUnlessDisabled(this.nextTarget)
    }
  }

  clickUnlessDisabled(button) {
    if (button.disabled) return
    button.click()
  }
}
