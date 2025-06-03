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

  /**
   * CSRFトークンをmetaタグから取得する
   * @type {string}
   */
  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }

  /**
   * 並び替えが完了したときに実行されるメインの処理
   */
  async onSortEnd(evt) {
    const { item, newIndex } = evt
    const itemId = item.dataset.imageId

    try {
      await this.#updatePosition(itemId, newIndex)
      this.#updateOrderNumbers()
    } catch {
      this.sortable.sort(this.sortable.toArray(), true)
      // Flash alertを表示
      const flashContainer = document.createElement('div')
      flashContainer.className = 'alert alert-danger'
      flashContainer.textContent = '並び替えに失敗しました'
      document.querySelector('h1').insertAdjacentElement('afterend', flashContainer)
    }
  }

  #updateOrderNumbers() {
    this.listTarget.querySelectorAll('tr').forEach((row, index) => {
      const orderCell = row.querySelector('.handle')
      if (orderCell) orderCell.textContent = `${index + 1}`
    })
  }

  /**
   * サーバーに新しい順序をPOSTリクエストで送信する
   */
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
