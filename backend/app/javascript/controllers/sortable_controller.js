import { Controller } from '@hotwired/stimulus'

/**
 * Sortable.js を利用してリストの並び替えを実装する
 */
export default class extends Controller {
  static targets = ['list']

  connect() {
    this.sortable = window.Sortable.create(this.listTarget, {
      animation: 150,
      handle: '.handle',
      ghostClass: 'sortable-ghost',
      onEnd: this.onSortEnd.bind(this)
    })
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }

  /**
   * ドラッグ＆ドロップ完了時に呼ばれる
   */
  async onSortEnd(evt) {
    const { item, newIndex } = evt
    const itemId = item.dataset.imageId

    try {
      await this.#updatePosition(itemId, newIndex)

      this.#updateOrderNumbers()
    } catch {
      // エラー時は DOM を元に戻す
      this.sortable.sort(this.sortable.toArray(), true)
      this.#showError()
    }
  }

  #updateOrderNumbers() {
    this.listTarget
      .querySelectorAll('.handle .order-number')
      .forEach((num, idx) => (num.textContent = idx + 1))
  }

  #showError() {
    const flashDiv = document.createElement('div')
    flashDiv.className = 'alert alert-danger'
    flashDiv.textContent = '並び替えに失敗しました'
    document.querySelector('.container').insertBefore(flashDiv, document.querySelector('.table-responsive'))
  }

  async #updatePosition(itemId, position) {
    const response = await fetch(`/admin/images/${itemId}/insert_at`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': this.csrfToken
      },
      body: JSON.stringify({ position })
    })

    if (!response.ok) throw new Error('Failed to update position')
  }
}
