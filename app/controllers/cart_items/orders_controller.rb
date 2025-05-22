class CartItems::OrdersController < ApplicationController
  rescue_from Cart::InvalidCartItemError, with: :handle_invalid_cart

  def create
    @cart = Cart.new(session[:cart_items], current_user)

    if @cart.checkout
      session[:cart_items] = nil
      flash[:notice] = t('carts.checkout_completed')
      redirect_to products_path
    else
      flash[:alert] = t('carts.checkout_failed')
      redirect_to cart_path
    end
  end

  private

  def handle_invalid_cart(error)
    flash[:alert] = error.message
    redirect_back(fallback_location: products_path)
  end
end
