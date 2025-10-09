import { Controller } from "@hotwired/stimulus"
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

    // Verificar que haya elementos arrastrables como hijos DIRECTOS
    const directChildren = Array.from(this.element.children)
    const sortableItems = directChildren.filter(el => el.dataset.sortableId)

    console.log('   Direct children:', directChildren.length)
    console.log('   Sortable items:', sortableItems.length)

    if (sortableItems.length === 0) {
      console.warn('⚠️ No sortable items found as direct children!')
      return
    }

    // Crear instancia de SortableJS
    this.sortable = Sortable.create(this.element, {
      animation: 200,
      handle: '.drag-handle',
      draggable: '[data-sortable-id]',
      ghostClass: 'sortable-ghost',
      chosenClass: 'sortable-chosen',
      dragClass: 'sortable-drag',

      onStart: (event) => {
        console.log('🟡 DRAG START for', this.typeValue)
        console.log('   Item:', event.item.id)
        event.item.classList.add('is-dragging')
        document.body.style.cursor = 'grabbing'
      },

      onEnd: (event) => {
        console.log('🟡 DRAG END for', this.typeValue)
        console.log('   From:', event.oldIndex, 'To:', event.newIndex)

        // Limpiar estilos
        event.item.classList.remove('is-dragging')
        document.body.style.cursor = ''

        // Solo actualizar si cambió de posición
        if (event.oldIndex !== event.newIndex) {
          console.log('   ➡️ Position changed, calling reorder...')
          this.updatePositions()
        } else {
          console.log('   ⏸️ No change, skipping')
        }
      }
    })

    console.log('✅ Sortable initialized successfully')
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
      this.sortable = null
    }
  }

  updatePositions() {
    console.log('🔵 UPDATE POSITIONS for', this.typeValue)

    // ⭐ IMPORTANTE: Usar children (hijos directos) en lugar de querySelectorAll
    const items = Array.from(this.element.children)
      .filter(el => el.dataset.sortableId)

    const ids = items.map(item => item.dataset.sortableId)

    console.log('   Items:', items.length)
    console.log('   IDs:', ids)

    if (ids.length === 0) {
      console.error('❌ No sortable items found!')
      return
    }

    const url = this.urlValue
    const payload = {
      type: this.typeValue,
      ids: ids
    }

    console.log('   Sending:', JSON.stringify(payload, null, 2))

    // Mostrar indicador visual
    this.element.style.opacity = '0.7'

    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.getCsrfToken(),
        'Accept': 'application/json'
      },
      body: JSON.stringify(payload)
    })
    .then(response => {
      console.log('✅ Response status:', response.status)
      return response.json()
    })
    .then(data => {
      console.log('✅ Response data:', data)

      // Restaurar opacidad
      this.element.style.opacity = '1'

      if (data.success) {
        console.log('🎉 Order saved!')
        this.showToast('Orden actualizado', 'success')
      }
    })
    .catch(error => {
      console.error('❌ Error:', error)
      this.element.style.opacity = '1'
      this.showToast('Error al actualizar', 'error')

      // Recargar después de 2 segundos
      setTimeout(() => {
        location.reload()
      }, 2000)
    })
  }

  getCsrfToken() {
    const token = document.querySelector('[name="csrf-token"]')
    return token ? token.content : ''
  }

  showToast(message, type = 'info') {
    const flashContainer = document.getElementById('flash_messages')
    if (!flashContainer) return

    const colors = {
      success: 'bg-green-50 border-green-200 text-green-800',
      error: 'bg-red-50 border-red-200 text-red-800',
      info: 'bg-blue-50 border-blue-200 text-blue-800'
    }

    const toast = document.createElement('div')
    toast.className = `${colors[type]} border rounded-md p-3 mb-2 shadow-sm`
    toast.textContent = message

    flashContainer.insertBefore(toast, flashContainer.firstChild)

    // Auto-remover
    setTimeout(() => {
      toast.style.opacity = '0'
      toast.style.transform = 'translateY(-10px)'
      toast.style.transition = 'all 0.3s'
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}
