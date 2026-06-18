import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

// On file selection, direct-uploads the file to the server, asks the server to
// resolve EXIF (camera/lens/taken_at) for the resulting blob, and fills the form.
// The human still confirms/edits before submitting. The blob is reused on submit
// (via a hidden signed_id field) so the file is uploaded only once.
export default class extends Controller {
  static targets = [
    "fileInput",
    "titleInput",
    "takenAtInput",
    "cameraSelect",
    "lensSelect",
    "status"
  ]

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }

  connect() {
    this.clearStatus()
  }

  fileSelected() {
    this.clearStatus()
    if (!this.hasFileInputTarget || this.fileInputTarget.files.length === 0) return

    const file = this.fileInputTarget.files[0]
    this.setStatus("EXIFデータを自動読み取り中...", "info")
    this.uploadAndFill(file)
  }

  async uploadAndFill(file) {
    try {
      const signedId = await this.directUpload(file)
      this.reuseUploadedBlob(signedId)
      const data = await this.fetchExif(signedId)
      this.applyExif(data, file)
    } catch (error) {
      console.error("EXIF自動入力エラー:", error)
      this.setStatus("EXIFデータの読み取りに失敗しました", "danger")
    }
  }

  directUpload(file) {
    const url = this.fileInputTarget.dataset.directUploadUrl
    const upload = new DirectUpload(file, url)
    return new Promise((resolve, reject) => {
      upload.create((error, blob) => (error ? reject(error) : resolve(blob.signed_id)))
    })
  }

  // Disable the file input (so the submit-time auto direct-upload skips it) and
  // carry the already-uploaded blob's signed_id as the file param instead.
  reuseUploadedBlob(signedId) {
    const name = this.fileInputTarget.name
    this.fileInputTarget.disabled = true

    let hidden = this.element.querySelector('input[data-exif-fill-file]')
    if (!hidden) {
      hidden = document.createElement("input")
      hidden.type = "hidden"
      hidden.name = name
      hidden.setAttribute("data-exif-fill-file", "")
      this.fileInputTarget.insertAdjacentElement("afterend", hidden)
    }
    hidden.value = signedId
  }

  async fetchExif(signedId) {
    const response = await fetch("/admin/images/extract_exif", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrfToken },
      body: JSON.stringify({ signed_id: signedId })
    })
    if (!response.ok) throw new Error(`extract_exif responded ${response.status}`)
    return response.json()
  }

  applyExif(data, file) {
    let updatedFields = 0

    if (data.taken_at && this.hasTakenAtInputTarget && !this.takenAtInputTarget.value) {
      this.takenAtInputTarget.value = data.taken_at
      updatedFields++
    }

    if (data.camera && this.hasCameraSelectTarget) {
      this.selectOption(this.cameraSelectTarget, data.camera)
      updatedFields++
    }

    if (data.lens && this.hasLensSelectTarget) {
      this.selectOption(this.lensSelectTarget, data.lens)
      updatedFields++
    }

    if (this.hasTitleInputTarget && !this.titleInputTarget.value) {
      this.titleInputTarget.value = file.name.replace(/\.[^/.]+$/, "")
      updatedFields++
    }

    if (updatedFields > 0) {
      this.setStatus(`✓ ${updatedFields}個のフィールドを自動更新しました`, "success")
    } else {
      this.setStatus("EXIFデータが見つかりませんでした", "warning")
    }
  }

  // Inject the option if the server returned a freshly created Camera/Lens that
  // wasn't in the select rendered at page load, then select it.
  selectOption(select, { id, label }) {
    const value = String(id)
    if (!Array.from(select.options).some((option) => option.value === value)) {
      select.add(new Option(label, value))
    }
    select.value = value
  }

  clearStatus() {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = ""
    this.statusTarget.className = ""
  }

  setStatus(msg, level = "info") {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = msg
    this.statusTarget.className = `text-${level} small mt-1`
  }
}
