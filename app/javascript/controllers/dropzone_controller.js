// app/javascript/controllers/dropzone_controller.js
import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "preview", "files", "count"]
  
  connect() {
    this.files = []
    this.maxFiles = 5 // Set this based on your LLM provider
    this.maxFileSize = 10 * 1024 * 1024 // 10MB
  }
  
  openFilePicker(event) {
    event.preventDefault()
    this.inputTarget.click()
  }
  
  clearFiles(event) {
    if (event) event.preventDefault()
    this.files = []
    this.inputTarget.value = ""
    this.filesTarget.innerHTML = ""
    this.countTarget.textContent = "0"
    this.previewTarget.classList.add("hidden")
  }
  
  submitForm(event) {
    if (this.files.length === 0 && !this.element.querySelector("textarea").value.trim()) {
      event.preventDefault()
      return
    }
  }
  
  filesChanged() {
    const newFiles = Array.from(this.inputTarget.files)
    
    // Check file limits
    if (this.files.length + newFiles.length > this.maxFiles) {
      this.showError(`You can only upload a maximum of ${this.maxFiles} files.`)
      this.inputTarget.value = ""
      return
    }
    
    // Check file sizes
    const oversizedFiles = newFiles.filter(file => file.size > this.maxFileSize)
    if (oversizedFiles.length > 0) {
      this.showError(`Some files exceed the ${this.formatFileSize(this.maxFileSize)} limit: ${oversizedFiles.map(f => f.name).join(", ")}`)
      this.inputTarget.value = ""
      return
    }
    
    // Process valid files
    newFiles.forEach(file => this.addFile(file))
  }
  
  addFile(file) {
    this.files.push(file)
    this.previewTarget.classList.remove("hidden")
    this.countTarget.textContent = this.files.length
    
    // Create preview element
    const fileItem = document.createElement("div")
    fileItem.className = "flex items-center rounded border border-zinc-200 bg-white p-2 dark:border-zinc-700 dark:bg-zinc-900"
    fileItem.dataset.fileId = this.files.length - 1
    
    // Add icon based on file type
    let iconSvg = ''
    if (file.type.includes('image')) {
      iconSvg = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 mr-2 text-zinc-500 dark:text-zinc-400">
        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z" />
      </svg>`
    } else {
      iconSvg = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 mr-2 text-zinc-500 dark:text-zinc-400">
        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
      </svg>`
    }
    
    fileItem.innerHTML = `
      <div class="flex-shrink-0">
        ${iconSvg}
      </div>
      <div class="flex-1 min-w-0 ml-2">
        <p class="truncate text-sm font-medium text-zinc-900 dark:text-white">${file.name}</p>
        <p class="text-xs text-zinc-500 dark:text-zinc-400">${this.formatFileSize(file.size)}</p>
      </div>
      <button type="button" data-action="click->dropzone#removeFile" data-file-id="${this.files.length - 1}" class="ml-2 text-zinc-500 hover:text-zinc-700 dark:text-zinc-400 dark:hover:text-zinc-300">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    `
    
    this.filesTarget.appendChild(fileItem)
    
    // Start the direct upload for this file
    this.uploadFile(file, this.files.length - 1)
  }
  
  removeFile(event) {
    const fileId = parseInt(event.currentTarget.dataset.fileId)
    this.files.splice(fileId, 1)
    
    // Rebuild the UI
    this.filesTarget.innerHTML = ""
    this.files.forEach((file, index) => {
      this.addFile(file)
    })
    
    this.countTarget.textContent = this.files.length
    if (this.files.length === 0) {
      this.previewTarget.classList.add("hidden")
    }
  }
  
  uploadFile(file, fileId) {
    // This would start the direct upload process, but for now
    // we'll just simulate it and set up the hidden input to 
    // include the file for form submission
    console.log(`Uploading file: ${file.name}`)
  }
  
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }
  
  showError(message) {
    const errorDiv = document.createElement("div")
    errorDiv.className = "bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4 rounded"
    errorDiv.innerHTML = `
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-500" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <p>${message}</p>
        </div>
      </div>
    `
    this.element.prepend(errorDiv)
    setTimeout(() => {
      errorDiv.remove()
    }, 5000)
  }
}