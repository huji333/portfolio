import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fileInput",
    "titleInput",
    "takenAtInput",
    "cameraSelect",
    "lensSelect",
    "status"
  ]

  static LENS_TAGS = [
    "LensModel", "Lens", "LensSpecification", "LensMake",
    "LensSerialNumber", "LensFirmwareVersion", "LensSpec"
  ]

  connect() {
    this.clearStatus()
  }

  fileSelected() {
    this.clearStatus()
    if (!this.hasFileInputTarget || this.fileInputTarget.files.length === 0) return

    const file = this.fileInputTarget.files[0]
    this.setStatus("EXIFデータを自動読み取り中...", "info")
    this.readExifData(file)
  }

  async readExifData(file) {
    try {
      window.EXIF.getData(file, async () => {
        let updatedFields = 0

        const dateTime = window.EXIF.getTag(file, "DateTimeOriginal")
        if (dateTime && this.hasTakenAtInputTarget && !this.takenAtInputTarget.value) {
          const isoDate = this.parseExifDateTime(file)
          if (isoDate) {
            this.takenAtInputTarget.value = isoDate
            updatedFields++
          }
        }

        const make = window.EXIF.getTag(file, "Make")
        const model = window.EXIF.getTag(file, "Model")
        if (make && model && this.hasCameraSelectTarget) {
          if (await this.lookupCamera(make, model)) updatedFields++
        }

        const lensName = this.extractLensName(file)
        if (lensName && lensName !== "undefined" && this.hasLensSelectTarget) {
          if (await this.lookupLens(lensName)) updatedFields++
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
      })
    } catch (error) {
      console.error("EXIF読み取りエラー:", error)
      this.setStatus("EXIFデータの読み取りに失敗しました", "danger")
    }
  }

  extractLensName(file) {
    for (const tag of this.constructor.LENS_TAGS) {
      const value = window.EXIF.getTag(file, tag)
      if (value && value !== "undefined") return value
    }

    const allTags = window.EXIF.getAllTags(file)
    if (allTags?.undefined && typeof allTags.undefined === 'string') {
      return allTags.undefined
    }
    return null
  }

  parseExifDateTime(file) {
    const dateTime = window.EXIF.getTag(file, "DateTimeOriginal")
    if (!dateTime) return null

    const match = dateTime.match(/(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})/)
    if (!match) return null

    const [, year, month, day, hour, minute, second] = match
    let localDateTime = `${year}-${month}-${day}T${hour}:${minute}`

    const offsetTime = window.EXIF.getTag(file, "OffsetTimeOriginal")
    if (offsetTime) {
      const offsetMatch = offsetTime.match(/([+-])(\d{2}):(\d{2})/)
      if (offsetMatch) {
        const [, sign, offsetHours, offsetMinutes] = offsetMatch
        const offsetMinutesTotal = parseInt(offsetHours) * 60 + parseInt(offsetMinutes)
        const offsetMs = (sign === '+' ? -offsetMinutesTotal : offsetMinutesTotal) * 60 * 1000

        const date = new Date(`${year}-${month}-${day}T${hour}:${minute}:${second}Z`)
        date.setTime(date.getTime() + offsetMs)
        localDateTime = date.toISOString().slice(0, 16)
      }
    }

    return localDateTime
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

  async lookupCamera(make, model) {
    try {
      const apiResponse = await fetch('/api/camera_name', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ make, model })
      })

      if (!apiResponse.ok) {
        if (apiResponse.status === 404) {
          this.showNotice(`カメラ "${make} ${model}" が見つかりませんでした。手動で選択してください。`)
        }
        return false
      }

      const apiData = await apiResponse.json()
      const lookupUrl = `/admin/cameras/lookup?camera_name=${encodeURIComponent(apiData.camera_name)}&manufacturer=${encodeURIComponent(apiData.manufacturer)}`
      const lookupResponse = await fetch(lookupUrl)

      if (lookupResponse.ok) {
        const camera = await lookupResponse.json()
        if (this.hasCameraSelectTarget) {
          this.cameraSelectTarget.value = camera.id
        }
        return true
      }

      const fallbackUrl = `/admin/cameras/lookup?camera_name=${encodeURIComponent(model)}&manufacturer=${encodeURIComponent(make)}`
      const fallbackResponse = await fetch(fallbackUrl)

      if (fallbackResponse.ok) {
        const fallbackCamera = await fallbackResponse.json()
        if (this.hasCameraSelectTarget) {
          this.cameraSelectTarget.value = fallbackCamera.id
        }
        return true
      }

      this.showNotice(`カメラ "${apiData.camera_name}" または "${make} ${model}" が見つかりませんでした。手動で選択してください。`)
      return false
    } catch (error) {
      console.error("カメラ情報の取得エラー:", error)
      this.showAlert("カメラ情報の取得中にエラーが発生しました。")
      return false
    }
  }

  async lookupLens(name) {
    try {
      const response = await fetch(`/admin/lenses/lookup?name=${encodeURIComponent(name)}`)
      if (response.ok) {
        const lens = await response.json()
        if (this.hasLensSelectTarget) {
          this.lensSelectTarget.value = lens.id
        }
        return true
      }
      return false
    } catch (error) {
      console.error("レンズ情報の取得エラー:", error)
      this.showAlert("レンズ情報の取得中にエラーが発生しました。")
      return false
    }
  }

  showNotice(message) {
    const form = this.element.closest('form')
    if (!form) return

    const alertDiv = document.createElement('div')
    alertDiv.className = 'alert alert-warning alert-dismissible fade show mt-2'
    alertDiv.innerHTML = `${message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>`

    form.insertBefore(alertDiv, form.firstChild)
    setTimeout(() => alertDiv.parentNode?.remove(), 5000)
  }

  showAlert(message) {
    alert(message)
  }
}
