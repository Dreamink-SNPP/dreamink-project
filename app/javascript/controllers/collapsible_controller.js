import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["content", "icon"]

    toggle(event) {
        const targetId = event.currentTarget.dataset.targetId
        const content = document.getElementById(targetId)
        const icon = event.currentTarget.querySelector('svg')

        if (content.classList.contains('hidden')) {
            content.classList.remove('hidden')
            icon.style.transform = 'rotate(0deg)'
        } else {
            content.classList.add('hidden')
            icon.style.transform = 'rotate(-90deg)'
        }
    }
}