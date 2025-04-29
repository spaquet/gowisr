// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];

  toggle() {
    this.menuTarget.classList.toggle("hidden");
  }

  // Optional: Close the dropdown when clicking outside
  close(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden");
    }
  }

  connect() {
    // Bind the close method to document click events
    document.addEventListener("click", this.close.bind(this));
  }

  disconnect() {
    // Clean up the event listener
    document.removeEventListener("click", this.close.bind(this));
  }
}