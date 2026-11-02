import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

// Moving an item moves its focused button too, which drops keyboard focus,
// so each action puts focus back on a sensible button and announces the change.
export default class extends Controller {
  static targets = ["ranked", "unranked", "modal", "modalTitle", "modalBody", "modalAdd", "modalClose", "status"]

  connect() {
    this.refresh()
    // A Stimulus action can't name this event, since it reads the dots as a key filter
    this.restoreFocus = this.restoreFocus.bind(this)
    this.modalTarget.addEventListener("hidden.bs.modal", this.restoreFocus)
  }

  disconnect() {
    this.modalTarget.removeEventListener("hidden.bs.modal", this.restoreFocus)
  }

  add(event) {
    const item = this.itemFor(event)
    const next = this.neighborButton(item, "add")
    this.addItem(item)
    this.focus(next ?? this.firstEnabled(item))
  }

  remove(event) {
    const item = this.itemFor(event)
    const next = this.neighborButton(item, "remove")
    const following = [...this.unrankedTarget.children].find(
      (other) => other.dataset.title.localeCompare(item.dataset.title) > 0
    )
    this.unrankedTarget.insertBefore(item, following ?? null)
    this.refresh()
    this.announce(`${item.dataset.title} removed from your list`)
    this.focus(next ?? this.button(item, "add"))
  }

  top(event) {
    this.move(event, (item) => this.rankedTarget.prepend(item))
  }

  up(event) {
    this.move(event, (item) => item.previousElementSibling?.before(item))
  }

  down(event) {
    this.move(event, (item) => item.nextElementSibling?.after(item))
  }

  bottom(event) {
    this.move(event, (item) => this.rankedTarget.append(item))
  }

  details(event) {
    this.detailsItem = this.itemFor(event)
    this.returnFocus = this.detailsItem.querySelector("[data-title-link]")
    const unranked = this.detailsItem.parentElement === this.unrankedTarget
    this.modalTitleTarget.textContent = this.detailsItem.dataset.title
    this.modalBodyTarget.replaceChildren(this.detailsItem.querySelector("template").content.cloneNode(true))
    this.modalAddTarget.hidden = !unranked
    this.modalCloseTarget.textContent = unranked ? "Cancel" : "Close"
    Modal.getOrCreateInstance(this.modalTarget).show()
  }

  addFromDetails() {
    const item = this.detailsItem
    this.returnFocus = this.neighborButton(item, "add") ?? this.firstEnabled(item)
    this.addItem(item)
    Modal.getOrCreateInstance(this.modalTarget).hide()
  }

  restoreFocus() {
    this.focus(this.returnFocus)
    this.returnFocus = null
  }

  move(event, place) {
    const item = this.itemFor(event)
    const action = event.currentTarget.dataset.move
    place(item)
    this.refresh()
    this.announceRank(item, "moved to")
    const same = this.button(item, action)
    this.focus(same.disabled ? this.firstEnabled(item) : same)
  }

  addItem(item) {
    this.rankedTarget.append(item)
    this.refresh()
    this.announceRank(item, "added at")
  }

  itemFor(event) {
    return event.currentTarget.closest("li")
  }

  button(item, move) {
    return item.querySelector(`[data-move='${move}']`)
  }

  firstEnabled(item) {
    return item.querySelector("[data-controls]:not([hidden]) button:not(:disabled)")
  }

  neighborButton(item, move) {
    const neighbor = item.nextElementSibling ?? item.previousElementSibling
    return neighbor && this.button(neighbor, move)
  }

  focus(element) {
    element?.focus()
  }

  announceRank(item, verb) {
    const ranked = [...this.rankedTarget.children]
    this.announce(`${item.dataset.title} ${verb} ${ranked.indexOf(item) + 1} of ${ranked.length}`)
  }

  // Clearing first makes screen readers repeat a message that hasn't changed
  announce(message) {
    this.statusTarget.textContent = ""
    requestAnimationFrame(() => { this.statusTarget.textContent = message })
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
      this.button(item, move).disabled = disabled
    }
  }
}
