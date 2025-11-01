import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    threshold: { type: Number, default: 300 }
  }

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll)
    this.handleScroll() // Check initial state
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  handleScroll() {
    const scrollPosition = window.pageYOffset || document.documentElement.scrollTop
    
    if (scrollPosition > this.thresholdValue) {
      this.buttonTarget.classList.remove("hidden", "opacity-0")
      this.buttonTarget.classList.add("opacity-100")
    } else {
      this.buttonTarget.classList.remove("opacity-100")
      this.buttonTarget.classList.add("opacity-0")
      // Hide completely after transition
      setTimeout(() => {
        if (this.buttonTarget.classList.contains("opacity-0")) {
          this.buttonTarget.classList.add("hidden")
        }
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
