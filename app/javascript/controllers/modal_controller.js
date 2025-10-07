import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container"]

    connect() {
        // Cerrar con ESC
        this.escapeHandler = (e) => {
            if (e.key === "Escape") {
                this.close()
            }
        }
        document.addEventListener("keydown", this.escapeHandler)
    }

    disconnect() {
        document.removeEventListener("keydown", this.escapeHandler)
    }

    open() {
        this.element.classList.remove("hidden")
        document.body.style.overflow = "hidden"
    }

    close() {
        this.element.classList.add("hidden")
        document.body.style.overflow = "auto"
    }

    closeBackground(event) {
        if (event.target === event.currentTarget) {
            this.close()
        }
    }
}