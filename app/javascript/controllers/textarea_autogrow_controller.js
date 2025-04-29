// app/javascript/controllers/textarea_autogrow_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.resize()
  }
  
  resize() {
    const textarea = this.element
    textarea.style.height = "auto"
    textarea.style.height = `${textarea.scrollHeight}px`
    
    // Set a max height if needed
    const maxHeight = 200 // in pixels
    if (textarea.scrollHeight > maxHeight) {
      textarea.style.height = `${maxHeight}px`
      textarea.style.overflowY = "auto"
    } else {
      textarea.style.overflowY = "hidden"
    }
  }
  
  handleKeydown(event) {
    // Submit on Enter (but not with Shift)
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.element.form.requestSubmit()
    }
  }
}