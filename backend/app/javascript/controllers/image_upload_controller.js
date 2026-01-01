import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "status"]
  static values  = {
    uploadUrl: String
  }

  connect() {
    // Drag & Drop イベントを親要素に付与
    this.element.addEventListener("dragover",  e => e.preventDefault())
    this.element.addEventListener("drop",      e => { e.preventDefault(); this.handleFiles(e.dataTransfer.files) })
  }

  fileSelected() { this.handleFiles(this.inputTarget.files) }

  async handleFiles(fileList) {
    const file = fileList[0]
    if (!file || !file.type.startsWith("image/")) return

    this.setStatus("アップロード中...", "info")

    const upload = new DirectUpload(file, this.uploadUrlValue)
    upload.create((err, blob) => {
      if (err) {
        console.error("Upload error:", err)
        return this.setStatus("アップロードエラー", "danger")
      }

      const hidden = document.createElement("input")
      hidden.type  = "hidden"
      hidden.name  = this.inputTarget.name
      hidden.value = blob.signed_id
      this.element.closest("form").appendChild(hidden)

      this.inputTarget.disabled = true
      this.inputTarget.style.display = "none"

      this.setStatus("✓ アップロード完了", "success")

      const exifController = this.application.getControllerForElementAndIdentifier(this.element, 'exif-reader')
      if (exifController) {
        exifController.updateExifButtonState()
      }
    })
  }

  setStatus(msg, level = "info") {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = msg
      this.statusTarget.className   = `text-${level} small mt-1`
    }
  }
}
