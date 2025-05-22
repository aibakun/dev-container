import orderApiClient from 'modules/order_api_client';

class OrderSubmissionHandler {
  static initialize() {
    const orderForm = document.getElementById('order-form');
    if (!orderForm || orderForm.dataset.initialized) return;

    orderForm.dataset.initialized = 'true';
    new OrderSubmissionHandler(orderForm);
  }

  constructor(formElement) {
    this.form = formElement;
    this.submitButton = this.form.querySelector('input[type="submit"]');

    if (this.submitButton) {
      this.originalButtonText = this.submitButton.dataset.originalText || this.submitButton.value;
      this.processingButtonText = this.submitButton.dataset.processingText || '処理中...';

      this.emptyOrderMessage = 'Please select items to order';
      this.errorMessage = 'An error occurred during order processing';
    }
    this.form.addEventListener('submit', this.handleSubmit.bind(this));
  }

  async handleSubmit(event) {
    event.preventDefault();

    if (this.submitButton) {
      this.submitButton.disabled = true;
      this.submitButton.value = this.processingButtonText;
    }

    try {
      const orderItems = this.getOrderItems();

      if (!orderItems.length) {
        this.form.submit();
        return;
      }

      const response = await orderApiClient.createOrder({
        orderDate: this.getOrderDate(),
        items: orderItems
      });

      if (response.order && response.order.id) {
        window.location.href = `/orders/${response.order.id}`;
      } else {
        window.location.href = '/orders';
      }

    } catch (error) {
      alert(error.message || this.errorMessage);
      this.enableSubmitButton();
    }
  }

  getOrderItems() {
    return Array.from(this.form.querySelectorAll('.order-item'))
      .map(row => {
        const select = row.querySelector('.product-select');
        if (select.selectedIndex <= 0) return null;

        const quantity = parseInt(row.querySelector('.quantity-input').value) || 0;

        return quantity > 0 ? {
          productSalesInfoId: select.value,
          quantity
        } : null;
      })
      .filter(Boolean);
  }

  getOrderDate() {
    const dateInput = this.form.querySelector('input[name="order[order_date]"]');
    return dateInput ? dateInput.value : null;
  }

  enableSubmitButton() {
    if (this.submitButton) {
      this.submitButton.disabled = false;
      this.submitButton.value = this.originalButtonText;
    }
  }
}

document.addEventListener('turbo:load', OrderSubmissionHandler.initialize);

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', OrderSubmissionHandler.initialize);
} else {
  OrderSubmissionHandler.initialize();
}

export default OrderSubmissionHandler;
