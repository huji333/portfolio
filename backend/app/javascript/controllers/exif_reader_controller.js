import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fileInput",
    "exifButton",
    "titleInput",
    "captionInput",
    "takenAtInput",
    "cameraSelect",
    "lensSelect",
    "exifMessage"
  ]

  connect() {
    this.updateExifButtonState()
    this.clearMessage()
  }

  // ファイルが選択された時の処理
  fileSelected() {
    this.updateExifButtonState()
    this.clearMessage()
  }

  // EXIFボタンの有効/無効状態を更新
  updateExifButtonState() {
    if (this.hasFileInputTarget && this.hasExifButtonTarget) {
      const fileCount = this.fileInputTarget.files.length
      if (fileCount > 0) {
        this.exifButtonTarget.disabled = false
      } else {
        this.exifButtonTarget.disabled = true
      }
    }
  }

  // EXIFデータを読み取ってフォームに反映
  readExifData() {
    if (!this.hasFileInputTarget || this.fileInputTarget.files.length === 0) {
      return
    }

    const file = this.fileInputTarget.files[0]
    this.exifButtonTarget.disabled = true
    this.exifButtonTarget.textContent = '読み取り中...'

    window.EXIF.getData(file, async () => {
      // DateTimeOriginal
      const dateTime = window.EXIF.getTag(file, "DateTimeOriginal")
      if (dateTime && this.hasTakenAtInputTarget) {
        const isoDate = this.parseExifDateTime(dateTime)
        this.takenAtInputTarget.value = isoDate
      }

      // Make, Model
      const make = window.EXIF.getTag(file, "Make")
      const model = window.EXIF.getTag(file, "Model")
      if (make && model) {
        await this.lookupCamera(make, model)
      }

      // LensModel
      const lensName = window.EXIF.getTag(file, "LensModel")
      if (lensName) {
        await this.lookupLens(lensName)
      }

      // タイトル
      if (this.hasTitleInputTarget && !this.titleInputTarget.value) {
        const fileName = file.name.replace(/\.[^/.]+$/, "")
        this.titleInputTarget.value = fileName
      }

      this.exifButtonTarget.textContent = 'EXIFデータを反映'
      this.exifButtonTarget.disabled = false
    })
  }

  // EXIF日時文字列をISO形式に変換
  parseExifDateTime(dateTimeString) {
    // EXIF日時形式: "2023:12:25 14:30:45" → ISO形式: "2023-12-25T14:30:45"
    const match = dateTimeString.match(/(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})/)
    if (match) {
      const [, year, month, day, hour, minute, second] = match
      return `${year}-${month}-${day}T${hour}:${minute}:${second}`
    }
    return null
  }

  clearMessage() {
    if (this.hasExifMessageTarget) {
      this.exifMessageTarget.textContent = ""
    }
  }

  showMessage(msg) {
    if (this.hasExifMessageTarget) {
      this.exifMessageTarget.textContent = msg
    }
  }

  // カメラをルックアップしてセレクトボックスに設定
  async lookupCamera(make, model) {
    try {
      const response = await fetch(`/admin/cameras/lookup?make=${encodeURIComponent(make)}&model=${encodeURIComponent(model)}`)

      if (response.ok) {
        const camera = await response.json()
        if (this.hasCameraSelectTarget) {
          this.cameraSelectTarget.value = camera.id
        }
        this.clearMessage()
      } else if (response.status === 404) {
        this.showMessage("カメラが見つかりませんでした")
      }
    } catch (error) {
      // エラー時は何もしない
    }
  }

  // レンズをルックアップしてセレクトボックスに設定
  async lookupLens(name) {
    try {
      const response = await fetch(`/admin/lenses/lookup?name=${encodeURIComponent(name)}`)

      if (response.ok) {
        const lens = await response.json()
        if (this.hasLensSelectTarget) {
          this.lensSelectTarget.value = lens.id
        }
        this.clearMessage()
      } else if (response.status === 404) {
        this.showMessage("レンズが見つかりませんでした")
      }
    } catch (error) {
      // エラー時は何もしない
    }
  }
}
