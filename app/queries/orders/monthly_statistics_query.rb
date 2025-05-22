module Orders
  class MonthlyStatisticsQuery
    class << self
      def call
        transform_results(
          active_orders
            .group(group_columns)
            .select(select_columns)
            .order(order_by_month)
            .limit(12)
        )
      end

      private

      def active_orders
        ::Order.active
      end

      def group_columns
        ['month']
      end

      def select_columns
        [
          monthly_date_column,
          order_count_column
        ].flatten
      end

      def monthly_date_column
        "DATE_TRUNC('month', order_date)::date as month"
      end

      def order_count_column
        'COUNT(*) as count'
      end

      def order_by_month
        'month ASC'
      end

      def transform_results(query_results)
        query_results.each_with_object({}) do |record, hash|
          hash[record.month] = record.count
        end
      end
    end
  end
end
