import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    threshold: { type: Number, default: 300 }
  }

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    this.hideTimeout = null
    window.addEventListener("scroll", this.handleScroll)
    this.handleScroll() // Check initial state
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
    // Clear pending timeout to prevent memory leak
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
      this.hideTimeout = null
    }
  }

  handleScroll() {
    const scrollPosition = window.pageYOffset || document.documentElement.scrollTop

    if (scrollPosition > this.thresholdValue) {
      // Clear any pending hide timeout when scrolling down
      if (this.hideTimeout) {
        clearTimeout(this.hideTimeout)
        this.hideTimeout = null
      }
      this.buttonTarget.classList.remove("hidden", "opacity-0")
      this.buttonTarget.classList.add("opacity-100")
    } else {
      this.buttonTarget.classList.remove("opacity-100")
      this.buttonTarget.classList.add("opacity-0")
      // Clear previous timeout before setting new one
      if (this.hideTimeout) {
        clearTimeout(this.hideTimeout)
      }
      // Hide completely after transition
      this.hideTimeout = setTimeout(() => {
        if (this.hasButtonTarget && this.buttonTarget.classList.contains("opacity-0")) {
          this.buttonTarget.classList.add("hidden")
        }
        this.hideTimeout = null
      }, 300)
    }
  }

  scrollToTop() {
    window.scrollTo({
      top: 0,
      behavior: "smooth"
    })
  }
}
