class OrderCreationService
  def initialize(user, order_params)
    @user = user
    @order_params = order_params
    @order_items_data = []
    @inventories = {}
  end

  def process
    parse_order_items

    raise ArgumentError, 'Order must have at least one item' if @order_items_data.empty?

    ActiveRecord::Base.transaction do
      validate_and_lock_inventories

      create_order

      create_shipment

      update_inventories
    end

    @order
  end

  private

  def parse_order_items
    product_sales_info_ids = @order_params[:product_sales_info_ids] || {}
    quantities = @order_params[:quantities] || {}

    product_sales_info_ids.each do |index, product_id|
      next if product_id.blank? || quantities[index].blank?

      quantity = quantities[index].to_i

      next if quantity <= 0

      @order_items_data << {
        product_sales_info_id: product_id,
        quantity: quantity
      }
    end
  end

  def validate_and_lock_inventories
    product_sales_info_ids = @order_items_data.map { |item| item[:product_sales_info_id] }

    product_sales_infos = ProductSalesInfo.includes(:inventory)
                                          .where(id: product_sales_info_ids)
                                          .index_by(&:id)

    @order_items_data.each do |item_data|
      product_sales_info = product_sales_infos[item_data[:product_sales_info_id].to_i]
      raise ActiveRecord::RecordNotFound, 'Product not found' if !product_sales_info
      inventory = product_sales_info.inventory.lock!

      if inventory.quantity < item_data[:quantity]
        raise Inventory::OutOfStockError,
              "Insufficient inventory for #{product_sales_info.name} (available: #{inventory.quantity}, requested: #{item_data[:quantity]})"
      end

      @inventories[product_sales_info.id] = {
        inventory: inventory,
        product_name: product_sales_info.name
      }
    end
  end

  def create_order
    @order = Order.new(order_date: @order_params[:order_date] || Date.current)
    @order.user = @user

    @order_items_data.each do |item_data|
      @order.order_items.build(item_data)
    end

    return if @order.save

    raise ActiveRecord::RecordInvalid.new(@order)
  end

  def create_shipment
    shipment = ShipmentFactory.create(@order)

    raise ActiveRecord::RecordInvalid.new(shipment) if !shipment.save
  end

  def update_inventories
    @order.order_items.each do |order_item|
      inventory_data = @inventories[order_item.product_sales_info_id]
      inventory = inventory_data[:inventory]
      new_quantity = inventory.quantity - order_item.quantity

      inventory.update_quantity!(new_quantity)
    end
  end
end
