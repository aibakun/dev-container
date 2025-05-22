const OrdersStatistics = {
  initialize: function() {
    if (document.getElementById('orders-statistics')) {
      this.fetchAndDisplayStatistics();
    }
  },

  fetchAndDisplayStatistics: async function() {
    try {
      const response = await fetch('/api/order_statistics');
      if (!response.ok) throw new Error('API request failed');

      const data = await response.json();
      this.updateStatisticsCards(data);
      this.initOrdersChart(data.monthly_statistics);
    } catch (error) {
      console.error('Failed to fetch statistics:', error);
    }
  },

  updateStatisticsCards: function(data) {
    document.getElementById('total-orders').textContent = data.total_orders;
    document.getElementById('active-orders').textContent = data.total_active_orders;
    document.getElementById('cancelled-orders').textContent = data.total_cancelled_orders;
  },

  initOrdersChart: function(monthlyData) {
    const ctx = document.getElementById('monthlyOrdersChart').getContext('2d');
    if (window.ordersChart) {
      window.ordersChart.destroy();
    }

    const chartLabel = document.getElementById('monthlyOrdersChart').dataset.chartLabel;

    window.ordersChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: Object.keys(monthlyData).map(date =>
          new Date(date).toLocaleDateString('ja-JP', { month: 'short', year: 'numeric' })
        ),
        datasets: [{
          label: chartLabel,
          data: Object.values(monthlyData),
          borderColor: 'rgb(75, 192, 192)',
          tension: 0.1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true,
            ticks: { precision: 0 }
          }
        }
      }
    });
  }
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', OrdersStatistics.initialize.bind(OrdersStatistics));
} else {
  OrdersStatistics.initialize();
}

document.addEventListener('turbo:load', OrdersStatistics.initialize.bind(OrdersStatistics));

export const initOrdersStatistics = OrdersStatistics.initialize.bind(OrdersStatistics);
