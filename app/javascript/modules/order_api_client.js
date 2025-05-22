class OrderApiClient {
  constructor() {
    this.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
    };
  }

  async createOrder(orderData) {
    try {
      const response = await fetch('/api/orders', {
        method: 'POST',
        headers: this.headers,
        credentials: 'same-origin',
        body: JSON.stringify({
          order: {
            order_date: orderData.orderDate,
            items: orderData.items.map(item => ({
              product_sales_info_id: item.productSalesInfoId,
              quantity: item.quantity
            }))
          }
        })
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to create order');
      }

      return data;
    } catch (error) {
      console.error('Error creating order:', error);
      throw error;
    }
  }
}

export default new OrderApiClient();
