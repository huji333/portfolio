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

  connect() {
    this.clearStatus()
  }

  fileSelected() {
    this.clearStatus()

    if (!this.hasFileInputTarget || this.fileInputTarget.files.length === 0) {
      return
    }

    const file = this.fileInputTarget.files[0]
    this.setStatus("EXIFデータを自動読み取り中...", "info")

    if (this.application.getControllerForElementAndIdentifier(this.element, 'image-upload')) {
      setTimeout(() => {
        this.readExifData(file)
      }, 200)
    } else {
      this.readExifData(file)
    }
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
          const success = await this.lookupCamera(make, model)
          if (success) updatedFields++
        }

        let lensName = window.EXIF.getTag(file, "LensModel")
        if (!lensName || lensName === "undefined") {
          lensName = window.EXIF.getTag(file, "Lens")
        }
        if (!lensName || lensName === "undefined") {
          lensName = window.EXIF.getTag(file, "LensSpecification")
        }
        if (!lensName || lensName === "undefined") {
          lensName = window.EXIF.getTag(file, "LensMake")
        }
        if (!lensName || lensName === "undefined") {
          lensName = window.EXIF.getTag(file, "LensModel")
        }
        if (!lensName || lensName === "undefined") {
          lensName = window.EXIF.getTag(file, "LensSerialNumber")
        }
        if (!lensName || lensName === "undefined") {
          lensName = window.EXIF.getTag(file, "LensFirmwareVersion")
        }
        if (!lensName || lensName === "undefined") {
          lensName = window.EXIF.getTag(file, "LensSpec")
        }

        // undefinedキーからレンズ情報を取得（フォールバック）
        if (!lensName || lensName === "undefined") {
          const allTags = window.EXIF.getAllTags(file)
          if (allTags.undefined && typeof allTags.undefined === 'string') {
            lensName = allTags.undefined
          }
        }

        if (lensName && lensName !== "undefined" && this.hasLensSelectTarget) {
          const success = await this.lookupLens(lensName)
          if (success) updatedFields++
        }

        if (this.hasTitleInputTarget && !this.titleInputTarget.value) {
          const fileName = file.name.replace(/\.[^/.]+$/, "")
          this.titleInputTarget.value = fileName
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

  parseExifDateTime(file) {
    const dateTime = window.EXIF.getTag(file, "DateTimeOriginal")
    if (!dateTime) return null

    const offsetTime = window.EXIF.getTag(file, "OffsetTimeOriginal")
    const match = dateTime.match(/(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})/)
    if (!match) return null

    const [, year, month, day, hour, minute, second] = match
    let localDateTime = `${year}-${month}-${day}T${hour}:${minute}`

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
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = ""
      this.statusTarget.className = ""
    }
  }

  setStatus(msg, level = "info") {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = msg
      this.statusTarget.className = `text-${level} small mt-1`
    }
  }

  async lookupCamera(make, model) {
    try {
      const apiResponse = await fetch('/api/camera_name', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          make: make,
          model: model
        })
      })

      if (apiResponse.ok) {
        const apiData = await apiResponse.json()
        const lookupUrl = `/admin/cameras/lookup?camera_name=${encodeURIComponent(apiData.camera_name)}&manufacturer=${encodeURIComponent(apiData.manufacturer)}`
        const lookupResponse = await fetch(lookupUrl)

        if (lookupResponse.ok) {
          const camera = await lookupResponse.json()
          if (this.hasCameraSelectTarget) {
            this.cameraSelectTarget.value = camera.id
          }
          return true
        } else if (lookupResponse.status === 404) {
          const fallbackUrl = `/admin/cameras/lookup?camera_name=${encodeURIComponent(model)}&manufacturer=${encodeURIComponent(make)}`
          const fallbackResponse = await fetch(fallbackUrl)

          if (fallbackResponse.ok) {
            const fallbackCamera = await fallbackResponse.json()
            if (this.hasCameraSelectTarget) {
              this.cameraSelectTarget.value = fallbackCamera.id
            }
            return true
          } else {
            this.showNotice(`カメラ "${apiData.camera_name}" または "${make} ${model}" が見つかりませんでした。手動で選択してください。`)
            return false
          }
        }
      } else if (apiResponse.status === 404) {
        this.showNotice(`カメラ "${make} ${model}" が見つかりませんでした。手動で選択してください。`)
        return false
      }
      return false
    } catch (error) {
      console.error("カメラ情報の取得エラー:", error)
      this.showAlert("カメラ情報の取得中にエラーが発生しました。")
      return false
    }
  }

  async lookupLens(name) {
    try {
      const lookupUrl = `/admin/lenses/lookup?name=${encodeURIComponent(name)}`
      const response = await fetch(lookupUrl)

      if (response.ok) {
        const lens = await response.json()
        if (this.hasLensSelectTarget) {
          this.lensSelectTarget.value = lens.id
        }
        return true
      } else if (response.status === 404) {
        return false
      }
      return false
    } catch (error) {
      console.error("レンズ情報の取得エラー:", error)
      this.showAlert("レンズ情報の取得中にエラーが発生しました。")
      return false
    }
  }

  showNotice(message) {
    const alertDiv = document.createElement('div')
    alertDiv.className = 'alert alert-warning alert-dismissible fade show mt-2'
    alertDiv.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `

    const form = this.element.closest('form')
    if (form) {
      form.insertBefore(alertDiv, form.firstChild)

      setTimeout(() => {
        if (alertDiv.parentNode) {
          alertDiv.remove()
        }
      }, 5000)
    }
  }

  showAlert(message) {
    alert(message)
  }
}
