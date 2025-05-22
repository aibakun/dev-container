class ShipmentStatusUpdater {
  static initialize() {
    const shipmentElement = document.querySelector('[data-shipment]')
    if (!shipmentElement || shipmentElement.dataset.initialized) return

    shipmentElement.dataset.initialized = 'true'
    new ShipmentStatusUpdater(shipmentElement)
  }

  constructor(element) {
    this.element = element
    this.statusElement = element.querySelector('[data-shipment-status]')
    this.buttonContainer = element.querySelector('[data-shipment-buttons]')
    this.shipmentId = element.dataset.shipmentId
    this.bindEvents()
  }

  bindEvents() {
    this.buttonContainer.addEventListener('click', (event) => {
      const button = event.target.closest('[data-action]')
      if (button) {
        event.preventDefault()
        this.updateStatus(button.dataset.action)
      }
    })
  }

  async updateStatus(action) {
    try {
      const response = await fetch(`/api/shipments/${this.shipmentId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ event: action })
      })

      const data = await response.json()

      if (response.ok) {
        this.statusElement.textContent = data.shipment.status_text
        this.element.dataset.currentStatus = data.shipment.status
        this.updateButtons(data.shipment.status)
      } else {
        alert('Failed to update shipment status: ' + data.error)
      }
    } catch (error) {
      alert('An error occurred while updating the shipment status')
    }
  }

  updateButtons(status) {
    const config = {
      'preparing': { action: 'ship', textKey: 'shipText' },
      'shipped': { action: 'begin_transit', textKey: 'transitText' },
      'in_transit': { action: 'mark_as_delivered', textKey: 'deliveredText' }
    }[status];

    if (!config) {
      this.buttonContainer.innerHTML = '';
      return;
    }

    let button = this.buttonContainer.querySelector('button');
    if (!button) {
      button = document.createElement('button');
      button.className = 'btn btn-primary';
      this.buttonContainer.appendChild(button);
    }

    button.dataset.action = config.action;
    button.textContent = this.element.dataset[config.textKey];
  }
}

document.addEventListener('turbo:load', ShipmentStatusUpdater.initialize)

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', ShipmentStatusUpdater.initialize)
} else {
  ShipmentStatusUpdater.initialize()
}

export default ShipmentStatusUpdater
