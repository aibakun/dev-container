module Api
  class InventoriesController < Api::InternalBaseController
    def show
      inventory = Inventory.find(params[:id])
      render json: inventory_response(inventory)
    rescue ActiveRecord::RecordNotFound
      render_error('Inventory not found', :not_found)
    end

    def update
      inventory = Inventory.find(params[:id])
      inventory.update_quantity!(params[:quantity].to_i)
      render json: inventory_response(inventory)
    rescue ActiveRecord::RecordNotFound
      render_error('Inventory not found', :not_found)
    rescue ArgumentError
      render_error('Invalid quantity', :unprocessable_entity)
    rescue Inventory::OutOfStockError
      render_error('Out of stock', :unprocessable_entity)
    end

    private

    def inventory_response(inventory)
      {
        id: inventory.id,
        product_id: inventory.product_id,
        quantity: inventory.quantity,
        low_stock: inventory.low_stock?
      }
    end
  end
end
