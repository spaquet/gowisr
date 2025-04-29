// app/javascript/controllers/theme_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lightIcon", "darkIcon"]

  connect() {
    console.debug("ThemeController connected")
    this.updateIcons()
  }

  toggle() {
    console.debug("ThemeController toggle")
    if (document.documentElement.classList.contains('dark')) {
      document.documentElement.classList.remove('dark')
      localStorage.theme = 'light'
    } else {
      document.documentElement.classList.add('dark')
      localStorage.theme = 'dark'
    }
    this.updateIcons()
  }

  updateIcons() {
    const isDark = document.documentElement.classList.contains('dark')
    
    if (this.hasLightIconTarget) {
      this.lightIconTarget.classList.toggle('hidden', isDark)
    }
    
    if (this.hasDarkIconTarget) {
      this.darkIconTarget.classList.toggle('hidden', !isDark)
    }
  }
}