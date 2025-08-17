import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"
import imageCompression from "browser-image-compression"

export default class extends Controller {
  static targets = ["input", "status"]
  static values  = {
    maxWidth:   { type: Number, default: 1920 },
    maxSize:    { type: Number, default: 4 },     // MB
    uploadUrl:  String                            // rails_direct_uploads_url
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

    this.setStatus("画像を圧縮中...", "info")

    try {
      // ① クライアント圧縮
      const compressed = await imageCompression(file, {
        maxWidthOrHeight: this.maxWidthValue,
        maxSizeMB:        this.maxSizeValue,
        useWebWorker:     true,
        exifOrientation:  true
      })

      this.setStatus("アップロード中...", "info")

      // ② DirectUpload
      const upload = new DirectUpload(compressed, this.uploadUrlValue)
      upload.create((err, blob) => {
        if (err) {
          console.error("Upload error:", err)
          return this.setStatus("アップロードエラー", "danger")
        }

        // ③ hidden input 生成
        const hidden = document.createElement("input")
        hidden.type  = "hidden"
        hidden.name  = this.inputTarget.name      // `image[file]` など
        hidden.value = blob.signed_id
        this.element.closest("form").appendChild(hidden)

        // 元のファイル入力を無効化
        this.inputTarget.disabled = true
        this.inputTarget.style.display = "none"

        this.setStatus("✓ アップロード完了", "success")

        // EXIFリーダーコントローラーに圧縮完了を通知
        const exifController = this.application.getControllerForElementAndIdentifier(this.element, 'exif-reader')
        if (exifController) {
          exifController.updateExifButtonState()
        }
      })
    } catch (error) {
      console.error("Compression error:", error)
      this.setStatus("圧縮エラー", "danger")
    }
  }

  setStatus(msg, level = "info") {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = msg
      this.statusTarget.className   = `text-${level} small mt-1`
    }
  }
}
