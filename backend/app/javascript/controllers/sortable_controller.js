import { Controller } from '@hotwired/stimulus'

/**
 * Sortable.js を利用してリストの並び替えを実装する
 *
 * 使う側の view で以下を指定する:
 * - data-sortable-url-value: `:id` プレースホルダ入りの insert_at パス
 *   （例: insert_at_admin_bucket_list_item_path(':id')）
 * - 各行に data-sortable-id
 */
export default class extends Controller {
  static targets = ['list']
  static values = { url: String }

  connect() {
    this._orderBeforeDrag = []
    this.sortable = window.Sortable.create(this.listTarget, {
      animation: 150,
      handle: '.handle',
      // ネイティブ HTML5 DnD はブラウザ差が大きく合成イベントにも応答しないため、
      // pointer ベースのフォールバックに固定して挙動を一貫させる（E2E も安定する）。
      forceFallback: true,
      ghostClass: 'sortable-ghost',
      dataIdAttr: 'data-sortable-id',
      onStart: () => { this._orderBeforeDrag = this.sortable.toArray() },
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
    const itemId = item.dataset.sortableId
    const savedOrder = this._orderBeforeDrag

    try {
      await this.#updatePosition(itemId, newIndex)

      this.#updateOrderNumbers()
    } catch {
      // エラー時は DOM を元に戻す
      this.sortable.sort(savedOrder, true)
      this.#showError()
    }
  }

  #updateOrderNumbers() {
    this.listTarget
      .querySelectorAll('.handle .order-number')
      .forEach((num, idx) => (num.textContent = idx + 1))
  }

  #showError() {
    document.querySelectorAll('.sortable-error-flash').forEach((el) => el.remove())
    const flashDiv = document.createElement('div')
    flashDiv.className = 'alert alert-danger sortable-error-flash'
    flashDiv.textContent = '並び替えに失敗しました'
    const container = document.querySelector('.container')
    if (container) {
      container.insertBefore(flashDiv, document.querySelector('.table-responsive'))
    }
  }

  async #updatePosition(itemId, position) {
    const response = await fetch(this.urlValue.replace(':id', itemId), {
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
