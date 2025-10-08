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
            handle: '.drag-handle', // Solo se puede arrastrar desde el handle
            ghostClass: 'sortable-ghost',
            chosenClass: 'sortable-chosen',
            dragClass: 'sortable-drag',
            onEnd: this.end.bind(this)
        })
    }

    disconnect() {
        if (this.sortable) {
            this.sortable.destroy()
        }
    }

    end(event) {
        const id = event.item.dataset.sortableId
        const newPosition = event.newIndex
        const oldPosition = event.oldIndex

        // Solo hacer la petición si cambió de posición
        if (oldPosition !== newPosition) {
            this.updatePosition(id, newPosition)
        }
    }

    updatePosition(id, position) {
        const url = this.urlValue.replace(':id', id)
        const type = this.typeValue

        fetch(url, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
            },
            body: JSON.stringify({
                position: position
            })
        })
            .then(response => {
                if (!response.ok) {
                    console.error('Error updating position')
                    // Revertir el cambio si falla
                    window.location.reload()
                }
            })
            .catch(error => {
                console.error('Error:', error)
                window.location.reload()
            })
    }
}