class ProductSalesInfosController < ApplicationController
  def index
    @products = Product.preload(:product_sales_infos).order(:id)
  end

  def new
    @product = Product.find(params[:product_id])
    @product_sales_info = @product.product_sales_infos.build
  end

  def create
    @product = Product.find(params[:product_id])
    @product_sales_info = @product.product_sales_infos.build(product_sales_info_params)

    if @product_sales_info.save
      redirect_to product_sales_infos_path, notice: t('.messages.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @product_sales_info = ProductSalesInfo.find(params[:id])
  end

  def update
    @product_sales_info = ProductSalesInfo.find(params[:id])
    if @product_sales_info.update(product_sales_info_params)
      redirect_to product_sales_infos_path, notice: t('.messages.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def product_sales_info_params
    params.require(:product_sales_info).permit(:price, :effective_from, :discontinued)
  end
end
