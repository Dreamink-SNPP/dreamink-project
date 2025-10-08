import {Controller} from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
    static values = {
        url: String,
        type: String  // 'act', 'sequence', o 'scene'
    }

    connect() {
        this.sortable = Sortable.create(this.element, {
            animation: 150,
            handle: '.drag-handle',
            ghostClass: 'sortable-ghost',
            chosenClass: 'sortable-chosen',
            dragClass: 'sortable-drag',
            onEnd: this.end.bind(this)
        })
    }

    disconnect() {
        if (this.sortable) {
            this.sortable.destroy()
            this.sortable = null
        }
    }

    end(event) {
        const oldPosition = event.oldIndex
        const newPosition = event.newIndex

        // Solo actualizar si cambió de posición
        if (oldPosition !== newPosition) {
            this.updateAllPositions()
        }
    }

    updateAllPositions() {
        // Obtener todos los elementos ordenados
        const items = Array.from(this.element.querySelectorAll('[data-sortable-id]'))

        // Crear un array con las IDs en el nuevo orden
        const orderedIds = items.map(item => item.dataset.sortableId)

        // Enviar todas las posiciones al backend
        const url = this.urlValue.replace('/:id/move', '/reorder')

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
            },
            body: JSON.stringify({
                type: this.typeValue,
                ids: orderedIds
            })
        })
            .then(response => {
                if (!response.ok) {
                    console.error('Error updating positions:', response.status)
                    throw new Error('Failed to update positions')
                }
                console.log(`✓ Positions updated successfully for ${this.typeValue}`)
            })
            .catch(error => {
                console.error('Error:', error)
                alert('Error al actualizar las posiciones. La página se recargará.')
                window.location.reload()
            })
    }
}