import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["button", "panel"]

    connect() {
        // Mostrar el primer tab por defecto
        this.showTab("internal")
    }

    switch(event) {
        const tabId = event.currentTarget.dataset.tabId
        this.showTab(tabId)
    }

    showTab(tabId) {
        // Actualizar botones
        this.buttonTargets.forEach(button => {
            if (button.dataset.tabId === tabId) {
                button.classList.add("active")
            } else {
                button.classList.remove("active")
            }
        })

        // Actualizar paneles
        this.panelTargets.forEach(panel => {
            if (panel.dataset.tabId === tabId) {
                panel.classList.remove("hidden")
            } else {
                panel.classList.add("hidden")
            }
        })
    }
}