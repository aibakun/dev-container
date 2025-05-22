module Api
  class OrderStatisticsController < Api::InternalBaseController
    def index
      render json: {
        total_orders: Order.count,
        total_active_orders: Order.active.count,
        total_cancelled_orders: Order.cancelled.count,
        monthly_statistics: Orders::MonthlyStatisticsQuery.call,
        product_statistics: Orders::ProductSalesStatisticsQuery.call
      }
    end
  end
end
