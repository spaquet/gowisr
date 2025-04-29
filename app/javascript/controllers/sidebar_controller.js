// app/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay"]

  connect() {
    // Initialize mobile sidebar state
    if (window.innerWidth < 1024) {
      this.panelTarget.classList.add('-translate-x-full')
    }
  }

  open() {
    this.panelTarget.classList.remove('-translate-x-full')
    this.overlayTarget.classList.remove('opacity-0', 'pointer-events-none')
    this.overlayTarget.classList.add('opacity-100')
  }

  close() {
    this.panelTarget.classList.add('-translate-x-full')
    this.overlayTarget.classList.remove('opacity-100')
    this.overlayTarget.classList.add('opacity-0', 'pointer-events-none')
  }
}