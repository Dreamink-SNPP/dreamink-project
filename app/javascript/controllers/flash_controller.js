import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        // Auto-cerrar después de 5 segundos
        const delay = this.element.dataset.flashDelayValue || 5000
        this.timeout = setTimeout(() => {
            this.close()
        }, delay)
    }

    close() {
        clearTimeout(this.timeout)
        this.element.remove()
    }

    disconnect() {
        clearTimeout(this.timeout)
    }
}