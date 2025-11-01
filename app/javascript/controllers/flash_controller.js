import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        // Slide in animation
        const initialClass = this.element.dataset.flashInitialClass || ''
        const enterClass = this.element.dataset.flashEnterClass || ''

        // Start with initial state (off-screen)
        if (initialClass) {
            initialClass.split(' ').forEach(cls => this.element.classList.add(cls))
        }

        // Trigger slide-in animation after a brief delay
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                if (initialClass) {
                    initialClass.split(' ').forEach(cls => this.element.classList.remove(cls))
                }
                if (enterClass) {
                    enterClass.split(' ').forEach(cls => this.element.classList.add(cls))
                }
            })
        })

        // Auto-close after delay
        const delay = this.element.dataset.flashDelayValue || 5000
        this.timeout = setTimeout(() => {
            this.close()
        }, delay)
    }

    close() {
        clearTimeout(this.timeout)

        // Slide out animation
        const exitClass = this.element.dataset.flashExitClass || ''
        const enterClass = this.element.dataset.flashEnterClass || ''

        if (enterClass) {
            enterClass.split(' ').forEach(cls => this.element.classList.remove(cls))
        }
        if (exitClass) {
            exitClass.split(' ').forEach(cls => this.element.classList.add(cls))
        }

        // Remove element after animation completes
        setTimeout(() => {
            this.element.remove()
        }, 300) // Match the duration-300 in CSS
    }

    disconnect() {
        clearTimeout(this.timeout)
    }
}