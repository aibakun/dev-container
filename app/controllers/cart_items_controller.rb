class CartItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from Cart::InvalidCartItemError, with: :handle_invalid_cart

  def create
    @cart = Cart.new(session[:cart_items], current_user)
    product = Product.joins(:product_sales_info).find(params[:product_id])
    quantity = params[:quantity].presence&.to_i || 1

    @cart.add_item(product, quantity)
    session[:cart_items] = @cart.cart_items
    flash[:notice] = t('carts.item_added')
    redirect_back(fallback_location: products_path)
  end

  def update
    @cart = Cart.new(session[:cart_items], current_user)
    product = Product.joins(:product_sales_info).find(params[:id])
    quantity = params[:quantity].presence&.to_i || 1

    @cart.update_quantity(product, quantity)
    session[:cart_items] = @cart.cart_items
    flash[:notice] = t('carts.quantity_updated')
    redirect_to cart_path
  end

  def destroy
    @cart = Cart.new(session[:cart_items], current_user)
    product = Product.find(params[:id])

    @cart.remove_item(product)
    session[:cart_items] = @cart.cart_items
    flash[:notice] = t('carts.item_removed')
    redirect_to cart_path
  end

  private

  def handle_record_not_found
    flash[:alert] = t('products.alerts.not_available')
    redirect_back(fallback_location: products_path)
  end

  def handle_invalid_cart(error)
    flash[:alert] = error.message
    redirect_back(fallback_location: products_path)
  end
end
