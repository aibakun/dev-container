module Orders
  class ProductSalesStatisticsQuery
    class << self
      def call
        transform_results(
          active_order_items
            .group(group_columns)
            .select(select_columns)
            .order(order_by_sales)
            .limit(10)
        )
      end

      private

      def active_order_items
        OrderItem.joins(order: [], product_sales_info: :product)
                 .merge(::Order.active)
      end

      def group_columns
        ['products.id', 'products.name']
      end

      def select_columns
        [
          product_columns,
          order_count_column,
          quantity_sum_column,
          sales_sum_column
        ].flatten
      end

      def product_columns
        [
          'products.id',
          'products.name'
        ]
      end

      def order_count_column
        'COUNT(DISTINCT order_items.order_id) as total_orders'
      end

      def quantity_sum_column
        'COALESCE(SUM(order_items.quantity), 0) as total_quantity'
      end

      def sales_sum_column
        'COALESCE(SUM(order_items.quantity * product_sales_infos.price), 0) as total_sales'
      end

      def order_by_sales
        'total_sales DESC NULLS LAST'
      end

      def transform_results(query_results)
        query_results.each_with_object({}) do |record, hash|
          hash[record.id] = {
            name: record.name,
            total_orders: record.total_orders,
            total_quantity: record.total_quantity,
            total_sales: record.total_sales
          }
        end
      end
    end
  end
end
