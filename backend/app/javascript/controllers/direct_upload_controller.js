import { Controller } from "@hotwired/stimulus"

// Handles ActiveStorage direct-upload lifecycle events to show
// upload progress and surface errors to the user.
export default class extends Controller {
  static targets = ["input", "progress", "error"]

  connect() {
    this._boundInitialize = this.onUploadInitialize.bind(this)
    this._boundProgress = this.progress.bind(this)
    this._boundError = this.error.bind(this)
    this._boundEnd = this.end.bind(this)

    this.element.addEventListener("direct-upload:initialize", this._boundInitialize)
    this.element.addEventListener("direct-upload:progress", this._boundProgress)
    this.element.addEventListener("direct-upload:error", this._boundError)
    this.element.addEventListener("direct-upload:end", this._boundEnd)
  }

  disconnect() {
    this.element.removeEventListener("direct-upload:initialize", this._boundInitialize)
    this.element.removeEventListener("direct-upload:progress", this._boundProgress)
    this.element.removeEventListener("direct-upload:error", this._boundError)
    this.element.removeEventListener("direct-upload:end", this._boundEnd)
  }

  onUploadInitialize(event) {
    this.clearError()
    this.progressTarget.classList.remove("d-none")
    this.updateProgressBar(0)
  }

  progress(event) {
    const { progress } = event.detail
    this.updateProgressBar(progress)
  }

  error(event) {
    event.preventDefault()
    const { error } = event.detail
    this.progressTarget.classList.add("d-none")
    this.errorTarget.classList.remove("d-none")
    this.errorTarget.textContent = `Upload failed: ${error}`
  }

  end(event) {
    this.updateProgressBar(100)
  }

  // private

  updateProgressBar(percent) {
    const bar = this.progressTarget.querySelector(".progress-bar")
    const rounded = Math.round(percent)
    bar.style.width = `${rounded}%`
    bar.setAttribute("aria-valuenow", rounded)
    bar.textContent = `${rounded}%`
  }

  clearError() {
    this.errorTarget.classList.add("d-none")
    this.errorTarget.textContent = ""
  }
}
