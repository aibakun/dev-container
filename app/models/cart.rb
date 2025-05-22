class Cart
  class InvalidCartItemError < StandardError; end

  attr_reader :cart_items, :user

  def initialize(cart_items, user)
    @cart_items = cart_items || []
    @user = user
  end

  def items
    @cart_items.map do |product_id, quantity|
      CartItem.new(
        product: Product.find(product_id),
        quantity: quantity
      )
    end
  end

  def add_item(product, quantity = 1)
    cart_item = CartItem.new(product: product, quantity: quantity)
    raise InvalidCartItemError, cart_item.errors.full_messages.join(', ') if cart_item.invalid?

    existing_item = find_cart_item(product.id)
    if existing_item
      _, current_quantity = existing_item
      existing_item[1] = current_quantity + quantity
    else
      @cart_items << [product.id, quantity]
    end

    cart_item
  end

  def update_quantity(product, quantity)
    return remove_item(product) if quantity.zero?

    cart_item = CartItem.new(product: product, quantity: quantity)
    raise InvalidCartItemError, cart_item.errors.full_messages.join(', ') if cart_item.invalid?

    existing_item = find_cart_item(product.id)
    if existing_item
      existing_item[1] = quantity
    else
      @cart_items << [product.id, quantity]
    end
  end

  def remove_item(product)
    @cart_items.delete_if { |product_id, _quantity| product_id == product.id }
  end

  def clear
    @cart_items.clear
  end

  def checkout
    return false if items.empty?

    create_order
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def find_cart_item(product_id)
    @cart_items.find { |stored_product_id, _quantity| stored_product_id == product_id }
  end

  def create_order
    ActiveRecord::Base.transaction do
      order = build_order
      order.save!
      clear
      order
    end
  end

  def build_order
    user.orders.new(order_date: Time.current).tap do |order|
      items.each do |item|
        order.order_items.build(
          product_sales_info: item.product.product_sales_info,
          quantity: item.quantity
        )
      end
    end
  end
end
