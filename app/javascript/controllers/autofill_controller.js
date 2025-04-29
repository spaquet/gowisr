// app/javascript/controllers/autofill_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  fillPrompt(event) {
    event.preventDefault()
    const prompt = event.currentTarget.dataset.prompt
    const textarea = document.querySelector('#message_content')
    
    if (textarea) {
      textarea.value = prompt
      // Trigger input event to resize the textarea
      textarea.dispatchEvent(new Event('input'))
      // Focus the textarea
      textarea.focus()
    }
  }
}