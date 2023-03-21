import { Controller } from "@hotwired/stimulus"
import SwaggerUI from 'swagger-ui'

export default class extends Controller {
  static targets = ["source"]
  static values = {
    url: String
  }

  connect() {
    if (!this.hasSourceTarget) { return }

    SwaggerUI({
      url: this.urlValue,
      dom_id: "#" + this.sourceTarget.id
    })
  }
}
