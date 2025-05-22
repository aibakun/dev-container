class OrderCancelsController < ApplicationController
  def new
    @order = current_user.orders.find(params[:order_id])
    @order_cancel = @order.build_order_cancel
  end

  def create
    @order = current_user.orders.find(params[:order_id])
    @order_cancel = @order.build_order_cancel(order_cancel_params)

    if @order_cancel.save
      redirect_to orders_path, notice: t('.messages.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.orders.find(params[:order_id]).order_cancel.destroy!
    redirect_to orders_path, notice: t('.messages.destroyed')
  end

  private

  def order_cancel_params
    params.require(:order_cancel).permit(:reason)
  end
end
