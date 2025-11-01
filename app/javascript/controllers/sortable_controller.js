import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    url: String,
    type: String,
    group: String,
    parentId: String
  }

  connect() {
    console.log('🟢 SORTABLE CONNECTED:', this.typeValue)
    console.log('   URL:', this.urlValue)
    console.log('   Group:', this.groupValue || 'none')
    console.log('   Parent ID:', this.parentIdValue || 'none')
    console.log('   Element:', this.element.id)

    const directChildren = Array.from(this.element.children)
    const sortableItems = directChildren.filter(el => el.dataset.sortableId)

    console.log('   Direct children:', directChildren.length)
    console.log('   Sortable items:', sortableItems.length)

    if (sortableItems.length === 0) {
      console.warn('⚠️ No sortable items found as direct children!')
    }

    const groupConfig = this.hasGroupValue ? {
      name: this.groupValue,
      pull: true,
      put: true
    } : false

    this.sortable = Sortable.create(this.element, {
      animation: 200,
      handle: '.drag-handle',
      draggable: '[data-sortable-id]',
      group: groupConfig,
      ghostClass: 'sortable-ghost',
      chosenClass: 'sortable-chosen',
      dragClass: 'sortable-drag',

      onStart: (event) => {
        console.log('🟡 DRAG START for', this.typeValue)
        console.log('   Item:', event.item.id)
        console.log('   From container:', event.from.id)
        event.item.classList.add('is-dragging')
        document.body.style.cursor = 'grabbing'
      },

      onEnd: (event) => {
        console.log('🟡 DRAG END for', this.typeValue)
        console.log('   From container:', event.from.id)
        console.log('   To container:', event.to.id)
        console.log('   Old index:', event.oldIndex, 'New index:', event.newIndex)

        event.item.classList.remove('is-dragging')
        document.body.style.cursor = ''

        const movedToNewContainer = event.from !== event.to

        if (movedToNewContainer) {
          console.log('   🔀 MOVED TO NEW CONTAINER!')
          this.handleCrossContainerMove(event)
        } else if (event.oldIndex !== event.newIndex) {
          console.log('   ↕️ REORDERED IN SAME CONTAINER')
          this.handleSameContainerReorder()
        } else {
          console.log('   ⏸️ No change')
        }
      }
    })

    console.log('✅ Sortable initialized')
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
      this.sortable = null
    }
  }

  handleCrossContainerMove(event) {
    const itemId = event.item.dataset.sortableId
    const newPosition = event.newIndex + 1  // acts_as_list uses positions base-1

    const newContainer = event.to
    const newParentId = newContainer.dataset.sortableParentId

    if (!newParentId) {
      console.error('❌ No parent ID found on target container')
      this.showToast('Error: contenedor sin ID', 'error')
      return
    }

    console.log(`   📤 Moving ${this.typeValue} ${itemId} to parent ${newParentId}, position ${newPosition}`)

    let endpoint, paramName

    if (this.typeValue === 'sequence') {
      endpoint = `/projects/${this.getProjectId()}/sequences/${itemId}/move_to_act`
      paramName = 'target_act_id'
    } else if (this.typeValue === 'scene') {
      endpoint = `/projects/${this.getProjectId()}/scenes/${itemId}/move_to_sequence`
      paramName = 'target_sequence_id'
    } else {
      console.error('❌ Unknown type:', this.typeValue)
      return
    }

    this.element.style.opacity = '0.7'

    const payload = {
      [paramName]: newParentId,
      target_position: newPosition
    }

    console.log('   📤 Sending PATCH to:', endpoint)
    console.log('   📦 Payload:', payload)

    fetch(endpoint, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.getCsrfToken(),
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify(payload)
    })
    .then(response => {
      console.log('   ✅ Response status:', response.status)
      this.element.style.opacity = '1'

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }
      return response.text()
    })
    .then(html => {
      console.log('   ✅ Turbo Stream response received')
      // Turbo.renderStreamMessage handles the Turbo Stream updates
      // Note: Toast message is already included in the Turbo Stream response
      if (typeof Turbo !== 'undefined') {
        Turbo.renderStreamMessage(html)
      }
    })
    .catch(error => {
      console.error('   ❌ Error:', error)
      this.element.style.opacity = '1'
      this.showToast('Error al mover. Recargando...', 'error')

      setTimeout(() => location.reload(), 2000)
    })
  }

  handleSameContainerReorder() {
    console.log('🔵 REORDERING IN SAME CONTAINER')

    const items = Array.from(this.element.children)
      .filter(el => el.dataset.sortableId)
    const ids = items.map(item => item.dataset.sortableId)

    console.log('   Items:', items.length)
    console.log('   IDs:', ids)

    if (ids.length === 0) {
      console.error('❌ No sortable items found!')
      return
    }

    const payload = {
      type: this.typeValue,
      ids: ids
    }

    console.log('   Sending:', JSON.stringify(payload, null, 2))

    this.element.style.opacity = '0.7'

    fetch(this.urlValue, {
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
      setTimeout(() => location.reload(), 2000)
    })
  }

  // Helpers
  getProjectId() {
    const match = window.location.pathname.match(/\/projects\/(\d+)/)
    return match ? match[1] : null
  }

  getCsrfToken() {
    const token = document.querySelector('[name="csrf-token"]')
    return token ? token.content : ''
  }

  showToast(message, type = 'info') {
    const flashContainer = document.getElementById('flash_messages')
    if (!flashContainer) return

    const toast = document.createElement('div')
    toast.className = 'bg-white rounded-lg shadow-lg p-4 pointer-events-auto transform transition-all duration-300 ease-out translate-x-full opacity-0'

    // Different border colors and icons for different types
    const config = {
      success: {
        borderColor: 'border-green-500',
        icon: `<svg class="h-5 w-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>`
      },
      error: {
        borderColor: 'border-red-500',
        icon: `<svg class="h-5 w-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>`
      },
      info: {
        borderColor: 'border-blue-500',
        icon: `<svg class="h-5 w-5 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>`
      }
    }

    const { borderColor, icon } = config[type] || config.info
    toast.classList.add('border-l-4', borderColor)

    toast.innerHTML = `
      <div class="flex items-start">
        <div class="flex-shrink-0">
          ${icon}
        </div>
        <div class="ml-3 flex-1">
          <p class="text-sm font-medium text-gray-900">${message}</p>
        </div>
        <button type="button" class="ml-3 inline-flex text-gray-400 hover:text-gray-600 transition close-toast">
          <span class="sr-only">Cerrar</span>
          <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>
          </svg>
        </button>
      </div>
    `

    flashContainer.appendChild(toast)

    // Slide in animation
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        toast.classList.remove('translate-x-full', 'opacity-0')
        toast.classList.add('translate-x-0', 'opacity-100')
      })
    })

    // Close button handler
    const closeButton = toast.querySelector('.close-toast')
    const closeToast = () => {
      toast.classList.remove('translate-x-0', 'opacity-100')
      toast.classList.add('translate-x-full', 'opacity-0')
      setTimeout(() => toast.remove(), 300)
    }
    closeButton.addEventListener('click', closeToast)

    // Auto-dismiss after 5 seconds
    setTimeout(closeToast, 5000)
  }
}
