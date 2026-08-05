import { Controller } from '@hotwired/stimulus'

/**
 * form 要素に付けて、配下の input の change で即送信する
 * （例: admin todo_items index の達成チェックボックス）
 *
 *   %form{ data: { controller: 'auto-submit' } }
 *     %input{ data: { action: 'change->auto-submit#submit' } }
 */
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
