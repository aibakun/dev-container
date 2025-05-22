class OrdersController < ApplicationController
  def index
    @orders = current_user.orders
                          .preload(:order_items, :order_cancel, order_items: :product_sales_info)
                          .order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def new
    @order = Order.new
    @order.order_items.build
    @available_products = ProductSalesInfo.joins(:product)
                                          .preload(:product)
                                          .where(discontinued: false)
                                          .where('effective_from <= ?', Time.current)
                                          .order('products.id')
  end

  def create
    @order = Order.new(order_date: params[:order][:order_date])
    @order.user_id = current_user.id

    params[:order][:product_sales_info_ids].each do |index, product_id|
      next if product_id.blank? || params[:order][:quantities][index].blank?

      @order.order_items.build(
        product_sales_info_id: product_id,
        quantity: params[:order][:quantities][index]
      )
    end

    ActiveRecord::Base.transaction do
      if @order.save
        ShipmentFactory.create(@order).save!
        redirect_to @order, notice: t('.messages.created')
      else
        @available_products = fetch_active_product_sales_info
        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordInvalid
      @available_products = fetch_active_product_sales_info
      render :new, status: :unprocessable_entity
    end
  end

  private

  def fetch_active_product_sales_info
    ProductSalesInfo.joins(:product)
                    .preload(:product)
                    .where(discontinued: false)
                    .where('effective_from <= ?', Time.current)
                    .order('products.id')
  end

  def order_params
    params.require(:order).permit(:order_date)
  end
end
