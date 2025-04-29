// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  connect() {
    // Close modal when ESC key is pressed
    document.addEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  open(event) {
    if (event) event.preventDefault()
    
    const modalId = event.currentTarget.dataset.modalTarget
    const modal = document.getElementById(modalId)
    
    if (modal) {
      modal.classList.remove('hidden')
      // Focus the first input if exists
      setTimeout(() => {
        const firstInput = modal.querySelector('input, textarea, select')
        if (firstInput) firstInput.focus()
      }, 100)
    }
  }
  
  close(event) {
    if (event) event.preventDefault()
    
    const modal = this.element
    modal.classList.add('hidden')
  }
  
  handleKeyDown(event) {
    if (event.key === 'Escape') {
      const visibleModals = document.querySelectorAll('[data-controller="modal"]:not(.hidden)')
      if (visibleModals.length > 0) {
        event.preventDefault()
        visibleModals.forEach(modal => {
          modal.classList.add('hidden')
        })
      }
    }
  }
}