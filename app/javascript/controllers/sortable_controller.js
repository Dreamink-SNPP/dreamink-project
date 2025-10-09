import {Controller} from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Controller para drag & drop con SortableJS
// Maneja el reordenamiento de actos, secuencias y escenas
export default class extends Controller {
    static values = {
        url: String,
        type: String  // 'act', 'sequence', o 'scene'
    }

    connect() {
        console.log(`Sortable connected: ${this.typeValue}`)

        this.sortable = Sortable.create(this.element, {
            animation: 200,
            handle: '.drag-handle',
            ghostClass: 'sortable-ghost',
            chosenClass: 'sortable-chosen',
            dragClass: 'sortable-drag',
            // Drag vertical solo para sequences y scenes
            direction: this.typeValue === 'act' ? 'horizontal' : 'vertical',
            // Prevenir drag fuera del contenedor
            fallbackTolerance: 3,
            forceFallback: true,
            // Callbacks
            onStart: this.onStart.bind(this),
            onEnd: this.onEnd.bind(this),
            onMove: this.onMove.bind(this)
        })
    }

    disconnect() {
        if (this.sortable) {
            this.sortable.destroy()
            this.sortable = null
        }
    }

    // ==========================================
    // CALLBACKS DE SORTABLEJS
    // ==========================================

    onStart(event) {
        // Agregar clase al elemento que se está arrastrando
        event.item.classList.add('is-dragging')

        // Feedback visual: cambiar cursor en all el documento
        document.body.style.cursor = 'grabbing'

        // Opcional: vibración en dispositivos móviles
        if (navigator.vibrate) {
            navigator.vibrate(50)
        }
    }

    onMove(event) {
        // Prevenir drops en lugares no permitidos
        const related = event.related

        // No permitir drops en elementos disabled o readonly
        if (related.hasAttribute('data-no-drop')) {
            return false
        }

        return true
    }

    onEnd(event) {
        // Remover clases temporales
        event.item.classList.remove('is-dragging')
        document.body.style.cursor = ''

        const oldPosition = event.oldIndex
        const newPosition = event.newIndex

        // Solo actualizar si cambió de posición
        if (oldPosition !== newPosition) {
            this.showLoadingState()
            this.updateAllPositions()
                .then(() => {
                    this.showSuccessState()
                })
                .catch((error) => {
                    this.showErrorState(error)
                    // Revertir el cambio visual
                    this.sortable.sort(this.getOriginalOrder())
                })
        }
    }

    // ==========================================
    // ACTUALIZACIÓN DE POSICIONES
    // ==========================================

    async updateAllPositions() {
        // Obtener todos los elementos ordenados
        const items = Array.from(this.element.querySelectorAll('[data-sortable-id]'))

        // Crear array con las IDs en el nuevo orden
        const orderedIds = items.map(item => item.dataset.sortableId)

        if (orderedIds.length === 0) {
            console.warn('No items found to reorder')
            return
        }

        // Construir URL
        const url = this.urlValue.replace('/:id/move', '/reorder')

        // Enviar al backend
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': this.getCsrfToken(),
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                type: this.typeValue,
                ids: orderedIds
            })
        })

        if (!response.ok) {
            const errorText = await response.text()
            throw new Error(`HTTP ${response.status}: ${errorText}`)
        }

        console.log(`✓ Positions updated successfully for ${this.typeValue}`)

        return response
    }

    // ==========================================
    // ESTADOS VISUALES
    // ==========================================

    showLoadingState() {
        // Mostrar indicador sutil de que está guardando
        this.element.classList.add('is-saving')

        // Opcional: mostrar spinner
        this.showToast('Guardando orden...', 'info')
    }

    showSuccessState() {
        this.element.classList.remove('is-saving')
        this.element.classList.add('save-success')

        // Remover clase después de la animación
        setTimeout(() => {
            this.element.classList.remove('save-success')
        }, 600)

        // Mostrar toast de éxito
        this.showToast('Orden actualizado', 'success')
    }

    showErrorState(error) {
        console.error('Error updating positions:', error)
        this.element.classList.remove('is-saving')
        this.element.classList.add('save-error')

        setTimeout(() => {
            this.element.classList.remove('save-error')
        }, 600)

        // Mostrar error al usuario
        this.showToast('Error al actualizar. La página se recargará.', 'error')

        // Recargar después de 2 segundos
        setTimeout(() => {
            window.location.reload()
        }, 2000)
    }

    // ==========================================
    // UTILIDADES
    // ==========================================

    getCsrfToken() {
        const token = document.querySelector('[name="csrf-token"]')
        return token ? token.content : ''
    }

    getOriginalOrder() {
        // Guardar orden original para poder revertir
        return Array.from(this.element.children).map(el => el.dataset.sortableId)
    }

    showToast(message, type = 'info') {
        // Buscar contenedor de flash messages
        const flashContainer = document.getElementById('flash_messages')
        if (!flashContainer) return

        // Crear toast
        const toast = document.createElement('div')
        toast.className = this.getToastClasses(type)
        toast.innerHTML = `
      <div class="flex items-center">
        ${this.getToastIcon(type)}
        <span class="ml-2 text-sm">${message}</span>
      </div>
    `

        // Agregar al DOM
        flashContainer.insertBefore(toast, flashContainer.firstChild)

        // Auto-remover después de 3 segundos
        setTimeout(() => {
            toast.style.opacity = '0'
            toast.style.transform = 'translateY(-10px)'
            setTimeout(() => toast.remove(), 300)
        }, 3000)
    }

    getToastClasses(type) {
        const baseClasses = 'rounded-md p-3 mb-2 shadow-sm transition-all duration-300'
        const typeClasses = {
            info: 'bg-blue-50 border border-blue-200 text-blue-800',
            success: 'bg-green-50 border border-green-200 text-green-800',
            error: 'bg-red-50 border border-red-200 text-red-800'
        }
        return `${baseClasses} ${typeClasses[type] || typeClasses.info}`
    }

    getToastIcon(type) {
        const icons = {
            info: '<svg class="h-5 w-5 text-blue-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/></svg>',
            success: '<svg class="h-5 w-5 text-green-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>',
            error: '<svg class="h-5 w-5 text-red-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/></svg>'
        }
        return icons[type] || icons.info
    }
}