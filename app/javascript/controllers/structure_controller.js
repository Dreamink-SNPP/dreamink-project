import {Controller} from "@hotwired/stimulus"

// Controller principal para la vista de estructura
// Maneja modales, carga dinámica de formularios y coordinación general
export default class extends Controller {
    static targets = [
        "newActModal",
        "editActModal",
        "newSequenceModal",
        "newSceneModal",
        "modalContent"
    ]

    static values = {
        projectId: Number
    }

    connect() {
        console.log("Structure controller connected")

        // Escuchar eventos de Turbo para cerrar modales después de submit exitoso
        this.boundHandleSuccess = this.handleTurboSuccess.bind(this)
        document.addEventListener("turbo:submit-end", this.boundHandleSuccess)

        // Cerrar modal con ESC
        this.boundHandleEscape = this.handleEscape.bind(this)
        document.addEventListener("keydown", this.boundHandleEscape)
    }

    disconnect() {
        // Limpiar event listeners cuando el controller se desconecta
        document.removeEventListener("turbo:submit-end", this.boundHandleSuccess)
        document.removeEventListener("keydown", this.boundHandleEscape)
    }

    // ==========================================
    // MÉTODOS PARA MODALES DE ACTO
    // ==========================================

    openNewActModal(event) {
        event?.preventDefault()
        this.showModal(this.newActModalTarget)
    }

    openEditActModal(event) {
        event.preventDefault()
        const actId = event.currentTarget.dataset.actId

        if (!actId) {
            console.error("No se encontró el act_id")
            return
        }

        const url = `/projects/${this.projectIdValue}/acts/${actId}/edit_modal`

        this.loadModalContent(this.editActModalTarget, url)
    }

    // ==========================================
    // MÉTODOS PARA MODALES DE SECUENCIA
    // ==========================================

    openNewSequenceModal(event) {
        event.preventDefault()
        const actId = event.currentTarget.dataset.actId

        if (!actId) {
            console.error("No se encontró el act_id")
            return
        }

        // Usar Turbo para cargar el formulario
        const url = `/projects/${this.projectIdValue}/acts/${actId}/sequences/new_modal`

        this.loadModalContent(this.newSequenceModalTarget, url)
    }

    // ==========================================
    // MÉTODOS PARA MODALES DE ESCENA
    // ==========================================

    openNewSceneModal(event) {
        event.preventDefault()
        const sequenceId = event.currentTarget.dataset.sequenceId

        if (!sequenceId) {
            console.error("No se encontró el sequence_id")
            return
        }

        // Usar Turbo para cargar el formulario
        const url = `/projects/${this.projectIdValue}/sequences/${sequenceId}/scenes/new_modal`

        this.loadModalContent(this.newSceneModalTarget, url)
    }

    // ==========================================
    // MÉTODOS AUXILIARES PARA MODALES
    // ==========================================

    showModal(modalElement) {
        if (!modalElement) {
            console.error("Modal element no encontrado")
            return
        }

        modalElement.classList.remove("hidden")
        document.body.style.overflow = "hidden"

        // Focus en el primer input del formulario
        setTimeout(() => {
            const firstInput = modalElement.querySelector("input, textarea")
            firstInput?.focus()
        }, 100)
    }

    closeModal(event) {
        event?.preventDefault()

        // Cerrar todos los modales
        const modals = [
            this.newActModalTarget,
            this.editActModalTarget,
            this.newSequenceModalTarget,
            this.newSceneModalTarget
        ]

        modals.forEach(modal => {
            if (modal) {
                modal.classList.add("hidden")
            }
        })

        document.body.style.overflow = "auto"
    }

    async loadModalContent(modalElement, url) {
        if (!modalElement) {
            console.error("Modal element no encontrado")
            return
        }

        // Buscar el contenedor del contenido dentro del modal
        const contentContainer = modalElement.querySelector("[data-modal-content]")

        if (!contentContainer) {
            console.error("Contenedor de contenido no encontrado en el modal")
            return
        }

        try {
            // Mostrar el modal primero
            this.showModal(modalElement)

            // Mostrar loading state
            contentContainer.innerHTML = `
        <div class="flex items-center justify-center py-8">
          <svg class="animate-spin h-8 w-8 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span class="ml-2 text-gray-600">Cargando...</span>
        </div>
      `

            // Cargar el contenido
            const response = await fetch(url, {
                headers: {
                    "Accept": "text/html",
                    "X-Requested-With": "XMLHttpRequest"
                }
            })

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`)
            }

            const html = await response.text()
            contentContainer.innerHTML = html

            // Focus en el primer input
            setTimeout(() => {
                const firstInput = contentContainer.querySelector("input, textarea")
                firstInput?.focus()
            }, 100)

        } catch (error) {
            console.error("Error cargando contenido del modal:", error)
            contentContainer.innerHTML = `
        <div class="text-center py-8">
          <p class="text-red-600">Error al cargar el formulario</p>
          <button
            data-action="click->structure#closeModal"
            class="mt-4 px-4 py-2 bg-gray-200 rounded hover:bg-gray-300">
            Cerrar
          </button>
        </div>
      `
        }
    }

    // ==========================================
    // EVENT HANDLERS
    // ==========================================

    handleTurboSuccess(event) {
        // Cerrar modal si el submit fue exitoso
        if (event.detail.success) {
            this.closeModal()
        }
    }

    handleEscape(event) {
        if (event.key === "Escape") {
            this.closeModal()
        }
    }

    // ==========================================
    // DEBUGGING
    // ==========================================

    logInfo() {
        console.log("Project ID:", this.projectIdValue)
        console.log("Modals:", {
            act: this.hasNewActModalTarget,
            editAct: this.hasEditActModalTarget,
            sequence: this.hasNewSequenceModalTarget,
            scene: this.hasNewSceneModalTarget
        })
    }
}
