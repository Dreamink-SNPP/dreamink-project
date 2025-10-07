import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    addTag(event) {
        const tag = event.currentTarget.dataset.tag
        const input = this.element.querySelector('input[name*="tags"]')

        if (!input) return

        const currentTags = input.value.split(',').map(t => t.trim()).filter(t => t)

        // No agregar si ya existe
        if (currentTags.includes(tag)) {
            return
        }

        // Agregar el tag
        if (currentTags.length > 0) {
            input.value = currentTags.join(', ') + ', ' + tag
        } else {
            input.value = tag
        }

        // Focus en el input
        input.focus()
    }
}