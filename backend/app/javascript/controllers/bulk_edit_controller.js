import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// 画像一覧の一括編集。全選択トグル・選択数の表示・操作バーの表示/非表示・
// キーボード操作（矢印で行移動、Space で選択、Enter で編集）を担当し、
// 送信は素のフォーム POST（PATCH bulk_update）に任せる。
export default class extends Controller {
  static targets = ["checkbox", "selectAll", "bar", "count", "submit", "row"]

  activeIndex = -1

  connect() {
    this.refresh()
  }

  toggleAll() {
    const checked = this.selectAllTarget.checked
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = checked
    })
    this.refresh()
  }

  refresh() {
    const count = this.checkboxTargets.filter((checkbox) => checkbox.checked).length
    this.barTarget.classList.toggle("d-none", count === 0)
    this.countTarget.textContent = count
    this.submitTarget.disabled = count === 0
    this.selectAllTarget.checked = count > 0 && count === this.checkboxTargets.length
    this.selectAllTarget.indeterminate = count > 0 && count < this.checkboxTargets.length
  }

  handleKeydown(event) {
    const target = event.target
    const isTextInput = /^(INPUT|SELECT|TEXTAREA)$/.test(target.tagName) && target.type !== "checkbox"
    if (isTextInput || event.metaKey || event.ctrlKey || event.altKey) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.moveActive(1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.moveActive(-1)
        break
      case " ":
        event.preventDefault()
        this.toggleActive()
        break
      case "Enter":
        this.visitActive()
        break
    }
  }

  moveActive(delta) {
    if (this.rowTargets.length === 0) return

    if (this.activeIndex === -1) {
      this.activeIndex = delta > 0 ? 0 : this.rowTargets.length - 1
    } else {
      const next = this.activeIndex + delta
      if (next < 0 || next >= this.rowTargets.length) return
      this.activeIndex = next
    }
    this.setActiveRow()
  }

  setActiveRow() {
    this.rowTargets.forEach((row) => row.classList.remove("bulk-edit-row-active"))
    const row = this.rowTargets[this.activeIndex]
    if (!row) return
    row.classList.add("bulk-edit-row-active")
    row.scrollIntoView({ block: "nearest" })
  }

  toggleActive() {
    const row = this.rowTargets[this.activeIndex]
    if (!row) return
    const checkbox = this.checkboxTargets.find((cb) => row.contains(cb))
    checkbox?.click()
  }

  visitActive() {
    const row = this.rowTargets[this.activeIndex]
    if (!row) return
    Turbo.visit(row.dataset.editUrl)
  }
}
