import {Controller} from "@hotwired/stimulus"

// Controller para elementos colapsables con animación suave
// Guarda el estado en localStorage para persistir entre sesiones
export default class extends Controller {
    static targets = ["content", "icon"]
    static values = {
        storageKey: String,  // Key única para guardar estado
        initialState: {type: String, default: "collapsed"} // 'expanded' o 'collapsed'
    }

    connect() {
        // Prevent initialization if we're inside a dragging element
        // This prevents nested controllers from reconnecting during parent drag
        const draggingParent = this.element.closest('.is-dragging')
        if (draggingParent) {
            console.log('⏸️ SKIPPING COLLAPSIBLE INIT (inside dragging parent)')
            return
        }

        console.log("Collapsible connected")

        // Restaurar estado guardado o usar inicial
        this.restoreState()
    }

    toggle(event) {
        event?.preventDefault()

        const targetId = event.currentTarget.dataset.targetId
        const content = document.getElementById(targetId)
        const icon = event.currentTarget.querySelector('svg')

        if (!content) {
            console.error(`Content element not found: ${targetId}`)
            return
        }

        const isExpanded = !content.classList.contains('hidden')

        if (isExpanded) {
            this.collapse(content, icon, targetId)
        } else {
            this.expand(content, icon, targetId)
        }
    }

    expand(content, icon, targetId) {
        // Remover hidden y agregar animación
        content.classList.remove('hidden')
        content.style.maxHeight = '0px'
        content.style.opacity = '0'

        // Trigger reflow
        void content.offsetHeight

        // Animar
        requestAnimationFrame(() => {
            content.style.transition = 'max-height 0.3s ease-out, opacity 0.3s ease-out'
            content.style.maxHeight = content.scrollHeight + 'px'
            content.style.opacity = '1'

            // Rotar icono
            if (icon) {
                icon.style.transition = 'transform 0.3s ease-out'
                icon.style.transform = 'rotate(0deg)'
            }
        })

        // Limpiar estilos inline después de la animación
        setTimeout(() => {
            content.style.maxHeight = ''
            content.style.opacity = ''
        }, 300)

        // Guardar estado
        this.saveState(targetId, 'expanded')
    }

    collapse(content, icon, targetId) {
        // Setear altura actual antes de colapsar
        content.style.maxHeight = content.scrollHeight + 'px'

        // Trigger reflow
        void content.offsetHeight

        // Animar colapso
        requestAnimationFrame(() => {
            content.style.transition = 'max-height 0.3s ease-out, opacity 0.3s ease-out'
            content.style.maxHeight = '0px'
            content.style.opacity = '0'

            // Rotar icono
            if (icon) {
                icon.style.transition = 'transform 0.3s ease-out'
                icon.style.transform = 'rotate(-90deg)'
            }
        })

        // Agregar hidden después de la animación
        setTimeout(() => {
            content.classList.add('hidden')
            content.style.maxHeight = ''
            content.style.opacity = ''
        }, 300)

        // Guardar estado
        this.saveState(targetId, 'collapsed')
    }

    // ==========================================
    // PERSISTENCIA DE ESTADO
    // ==========================================

    saveState(targetId, state) {
        if (!this.hasStorageKeyValue) return

        try {
            const key = `${this.storageKeyValue}_${targetId}`
            localStorage.setItem(key, state)
        } catch (error) {
            console.warn('Could not save collapsible state:', error)
        }
    }

    restoreState() {
        if (!this.hasStorageKeyValue) return

        // Buscar todos los collapsibles en este controller
        const buttons = this.element.querySelectorAll('[data-action*="collapsible#toggle"]')

        buttons.forEach(button => {
            const targetId = button.dataset.targetId
            if (!targetId) return

            try {
                const key = `${this.storageKeyValue}_${targetId}`
                const savedState = localStorage.getItem(key)

                if (savedState) {
                    const content = document.getElementById(targetId)
                    const icon = button.querySelector('svg')

                    if (content && savedState === 'expanded') {
                        // Expandir sin animación al cargar
                        content.classList.remove('hidden')
                        if (icon) {
                            icon.style.transform = 'rotate(0deg)'
                        }
                    } else if (content && savedState === 'collapsed') {
                        content.classList.add('hidden')
                        if (icon) {
                            icon.style.transform = 'rotate(-90deg)'
                        }
                    }
                }
            } catch (error) {
                console.warn('Could not restore collapsible state:', error)
            }
        })
    }

    // ==========================================
    // MÉTODOS PÚBLICOS
    // ==========================================

    expandAll() {
        const buttons = this.element.querySelectorAll('[data-action*="collapsible#toggle"]')
        buttons.forEach(button => {
            const targetId = button.dataset.targetId
            const content = document.getElementById(targetId)
            const icon = button.querySelector('svg')

            if (content && content.classList.contains('hidden')) {
                this.expand(content, icon, targetId)
            }
        })
    }

    collapseAll() {
        const buttons = this.element.querySelectorAll('[data-action*="collapsible#toggle"]')
        buttons.forEach(button => {
            const targetId = button.dataset.targetId
            const content = document.getElementById(targetId)
            const icon = button.querySelector('svg')

            if (content && !content.classList.contains('hidden')) {
                this.collapse(content, icon, targetId)
            }
        })
    }
}