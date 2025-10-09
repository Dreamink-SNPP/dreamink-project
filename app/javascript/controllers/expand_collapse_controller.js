import {Controller} from "@hotwired/stimulus"

// Controller para manejar expandir/colapsar todos los elementos
export default class extends Controller {
    static targets = ["expandButton", "collapseButton"]

    connect() {
        console.log("Expand/Collapse controller connected")
    }

    expandAll(event) {
        event?.preventDefault()

        // Buscar todos los elementos colapsables
        const collapsibles = document.querySelectorAll('[data-controller*="collapsible"]')

        collapsibles.forEach(element => {
            // Buscar los botones de toggle dentro de cada collapsible
            const toggleButtons = element.querySelectorAll('[data-action*="collapsible#toggle"]')

            toggleButtons.forEach(button => {
                const targetId = button.dataset.targetId
                const content = document.getElementById(targetId)
                const icon = button.querySelector('svg')

                // Solo expandir si está colapsado
                if (content && content.classList.contains('hidden')) {
                    this.expand(content, icon)
                }
            })
        })

        this.showFeedback('Todas las secuencias expandidas', 'success')
    }

    collapseAll(event) {
        event?.preventDefault()

        const collapsibles = document.querySelectorAll('[data-controller*="collapsible"]')

        collapsibles.forEach(element => {
            const toggleButtons = element.querySelectorAll('[data-action*="collapsible#toggle"]')

            toggleButtons.forEach(button => {
                const targetId = button.dataset.targetId
                const content = document.getElementById(targetId)
                const icon = button.querySelector('svg')

                // Solo colapsar si está expandido
                if (content && !content.classList.contains('hidden')) {
                    this.collapse(content, icon)
                }
            })
        })

        this.showFeedback('Todas las secuencias colapsadas', 'info')
    }

    // ==========================================
    // MÉTODOS DE ANIMACIÓN
    // ==========================================

    expand(content, icon) {
        content.classList.remove('hidden')
        content.style.maxHeight = '0px'
        content.style.opacity = '0'

        void content.offsetHeight

        requestAnimationFrame(() => {
            content.style.transition = 'max-height 0.3s ease-out, opacity 0.3s ease-out'
            content.style.maxHeight = content.scrollHeight + 'px'
            content.style.opacity = '1'

            if (icon) {
                icon.style.transition = 'transform 0.3s ease-out'
                icon.style.transform = 'rotate(0deg)'
            }
        })

        setTimeout(() => {
            content.style.maxHeight = ''
            content.style.opacity = ''
        }, 300)
    }

    collapse(content, icon) {
        content.style.maxHeight = content.scrollHeight + 'px'

        void content.offsetHeight

        requestAnimationFrame(() => {
            content.style.transition = 'max-height 0.3s ease-out, opacity 0.3s ease-out'
            content.style.maxHeight = '0px'
            content.style.opacity = '0'

            if (icon) {
                icon.style.transition = 'transform 0.3s ease-out'
                icon.style.transform = 'rotate(-90deg)'
            }
        })

        setTimeout(() => {
            content.classList.add('hidden')
            content.style.maxHeight = ''
            content.style.opacity = ''
        }, 300)
    }

    // ==========================================
    // FEEDBACK VISUAL
    // ==========================================

    showFeedback(message, type = 'info') {
        const flashContainer = document.getElementById('flash_messages')
        if (!flashContainer) return

        const toast = document.createElement('div')
        toast.className = this.getToastClasses(type)
        toast.innerHTML = `
      <div class="flex items-center">
        <span class="text-sm">${message}</span>
      </div>
    `

        flashContainer.insertBefore(toast, flashContainer.firstChild)

        setTimeout(() => {
            toast.style.opacity = '0'
            toast.style.transform = 'translateY(-10px)'
            setTimeout(() => toast.remove(), 300)
        }, 2000)
    }

    getToastClasses(type) {
        const baseClasses = 'rounded-md p-3 mb-2 shadow-sm transition-all duration-300'
        const typeClasses = {
            info: 'bg-blue-50 border border-blue-200 text-blue-800',
            success: 'bg-green-50 border border-green-200 text-green-800'
        }
        return `${baseClasses} ${typeClasses[type] || typeClasses.info}`
    }
}