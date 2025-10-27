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
        'Accept': 'application/json'
      },
      body: JSON.stringify(payload)
    })
    .then(response => {
      console.log('   ✅ Response status:', response.status)
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }
      return response.json()
    })
    .then(data => {
      console.log('   ✅ Response data:', data)
      this.element.style.opacity = '1'

      if (data.success) {
        this.showToast('Elemento movido correctamente', 'success')
      } else {
        throw new Error('Server returned success: false')
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

    const colors = {
      success: 'bg-green-50 border-green-200 text-green-800',
      error: 'bg-red-50 border-red-200 text-red-800',
      info: 'bg-blue-50 border-blue-200 text-blue-800'
    }

    const toast = document.createElement('div')
    toast.className = `${colors[type]} border rounded-md p-3 mb-2 shadow-sm`
    toast.textContent = message

    flashContainer.insertBefore(toast, flashContainer.firstChild)

    setTimeout(() => {
      toast.style.opacity = '0'
      toast.style.transform = 'translateY(-10px)'
      toast.style.transition = 'all 0.3s'
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}
