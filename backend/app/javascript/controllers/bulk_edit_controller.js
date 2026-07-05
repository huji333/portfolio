import { Controller } from "@hotwired/stimulus"

// 画像一覧の一括編集。全選択トグル・選択数の表示・操作バーの表示/非表示だけを
// 担当し、送信は素のフォーム POST（PATCH bulk_update）に任せる。
export default class extends Controller {
  static targets = ["checkbox", "selectAll", "bar", "count", "submit"]

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
}
