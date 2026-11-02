import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["ranked", "unranked", "modal", "modalTitle", "modalBody", "modalAdd", "modalClose"]

  connect() {
    this.refresh()
  }

  add(event) {
    this.rankedTarget.append(this.itemFor(event))
    this.refresh()
  }

  remove(event) {
    const item = this.itemFor(event)
    const next = [...this.unrankedTarget.children].find(
      (other) => other.dataset.title.localeCompare(item.dataset.title) > 0
    )
    this.unrankedTarget.insertBefore(item, next ?? null)
    this.refresh()
  }

  top(event) {
    this.rankedTarget.prepend(this.itemFor(event))
    this.refresh()
  }

  up(event) {
    const item = this.itemFor(event)
    item.previousElementSibling?.before(item)
    this.refresh()
  }

  down(event) {
    const item = this.itemFor(event)
    item.nextElementSibling?.after(item)
    this.refresh()
  }

  bottom(event) {
    this.rankedTarget.append(this.itemFor(event))
    this.refresh()
  }

  details(event) {
    this.detailsItem = this.itemFor(event)
    const unranked = this.detailsItem.parentElement === this.unrankedTarget
    this.modalTitleTarget.textContent = this.detailsItem.dataset.title
    this.modalBodyTarget.replaceChildren(this.detailsItem.querySelector("template").content.cloneNode(true))
    this.modalAddTarget.hidden = !unranked
    this.modalCloseTarget.textContent = unranked ? "Cancel" : "Close"
    Modal.getOrCreateInstance(this.modalTarget).show()
  }

  addFromDetails() {
    this.rankedTarget.append(this.detailsItem)
    this.refresh()
    Modal.getOrCreateInstance(this.modalTarget).hide()
  }

  itemFor(event) {
    return event.currentTarget.closest("li")
  }

  refresh() {
    const ranked = [...this.rankedTarget.children]
    ranked.forEach((item, index) => {
      this.setRanked(item, true)
      this.setDisabled(item, ["top", "up"], index === 0)
      this.setDisabled(item, ["down", "bottom"], index === ranked.length - 1)
    })
    for (const item of this.unrankedTarget.children) {
      this.setRanked(item, false)
    }
  }

  setRanked(item, ranked) {
    item.querySelector("input").disabled = !ranked
    item.querySelector("[data-controls='ranked']").hidden = !ranked
    item.querySelector("[data-controls='unranked']").hidden = ranked
  }

  setDisabled(item, moves, disabled) {
    for (const move of moves) {
      item.querySelector(`[data-move='${move}']`).disabled = disabled
    }
  }
}
