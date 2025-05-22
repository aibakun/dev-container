class CartsController < ApplicationController
  def show
    @cart = Cart.new(session[:cart_items], current_user)
  end
end
