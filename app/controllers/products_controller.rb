class ProductsController < ApplicationController
  def index
    @page = [params[:page].to_i, 1].max
    per_page = 10
    @products = Product.joins(:product_sales_info)
                       .preload(:product_sales_info)
                       .page(@page, per_page)
    @total_pages = Product.total_pages(per_page)
  end

  def show
    @product = Product.joins(:product_sales_info)
                      .find(params[:id])
    @sales_info = @product.product_sales_info
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('products.alerts.not_available')
    redirect_to products_path
  end
end
