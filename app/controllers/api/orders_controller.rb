module Api
  class OrdersController < Api::InternalBaseController
    def create
      service = OrderCreationService.new(current_user, order_params)

      @order = service.process
      render json: {
        status: :created,
        message: I18n.t('orders.messages.created'),
        order: @order.as_json(only: %i[id order_date created_at])
      }, status: :created
    rescue Inventory::OutOfStockError => e
      render_error(e.message, :unprocessable_entity)
    rescue ActiveRecord::RecordInvalid => e
      render_error(e.record.errors.full_messages, :unprocessable_entity)
    rescue ArgumentError => e
      render_error(e.message, :bad_request)
    rescue ActiveRecord::RecordNotFound => e
      render_error(e.message, :not_found)
    end

    private

    def order_params
      items = params.require(:order).permit(items: %i[product_sales_info_id quantity])[:items] || []

      product_sales_info_ids = {}
      quantities = {}

      items.each_with_index do |item, index|
        next if item[:product_sales_info_id].blank? || item[:quantity].blank?
        next if item[:quantity].to_i <= 0

        idx = index.to_s
        product_sales_info_ids[idx] = item[:product_sales_info_id]
        quantities[idx] = item[:quantity]
      end

      {
        order_date: params.dig(:order, :order_date) || Date.current,
        product_sales_info_ids: product_sales_info_ids,
        quantities: quantities
      }
    end
  end
end
