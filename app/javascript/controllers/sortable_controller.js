import {Controller} from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
    static values = {
        url: String,
        type: String
    }

    connect() {
        console.log('🟢 SORTABLE CONNECTED:', this.typeValue)
        console.log('   URL:', this.urlValue)
        console.log('   Element:', this.element.id)

        this.sortable = Sortable.create(this.element, {
            animation: 150,
            handle: '.drag-handle',
            onEnd: (event) => {
                console.log('🟡 DRAG END for', this.typeValue)
                console.log('   From index:', event.oldIndex)
                console.log('   To index:', event.newIndex)
                console.log('   Element ID:', this.element.id)

                if (event.oldIndex !== event.newIndex) {
                    console.log('   ➡️ Calling reorder...')
                    this.reorder()
                } else {
                    console.log('   ⏸️ No change, skipping')
                }
            }
        })
    }

    disconnect() {
        if (this.sortable) {
            this.sortable.destroy()
        }
    }

    reorder() {
        console.log('🔵 REORDER called for', this.typeValue)

        const items = Array.from(this.element.querySelectorAll('[data-sortable-id]'))
        const ids = items.map(item => item.dataset.sortableId)

        console.log('   Items found:', items.length)
        console.log('   IDs:', ids)
        console.log('   URL:', this.urlValue)

        if (ids.length === 0) {
            console.error('❌ No items found with data-sortable-id!')
            return
        }

        const url = this.urlValue
        const payload = {
            type: this.typeValue,
            ids: ids
        }

        console.log('   Payload:', JSON.stringify(payload, null, 2))

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
            },
            body: JSON.stringify(payload)
        })
            .then(response => {
                console.log('✅ Response status:', response.status)
                return response.json()
            })
            .then(data => {
                console.log('✅ Response data:', data)
                if (data.success) {
                    console.log('🎉 Order saved successfully!')
                }
            })
            .catch(error => {
                console.error('❌ Error:', error)
                alert('Error al actualizar. Recargando...')
                location.reload()
            })
    }
}