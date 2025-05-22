require 'rails_helper'

RSpec.describe 'Products', type: :request do
  let(:user) { create(:user) }
  let!(:product) { create(:product) }

  before do
    login(user, 'password')
    create(:permission, user: user, controller: 'products', action: 'index')
    create(:permission, user: user, controller: 'products', action: 'show')
  end

  describe 'GET /products' do
    it 'returns a list of available products' do
      product_with_active_sales = create(:product)
      create(:product_sales_info, product: product_with_active_sales)

      discontinued_product = create(:product)
      create(:product_sales_info, :discontinued, product: discontinued_product)

      future_product = create(:product)
      create(:product_sales_info, effective_from: 1.day.from_now, product: future_product)

      get products_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /products/:id' do
    context 'when product is available' do
      it 'shows the product details' do
        available_product = create(:product)
        create(:product_sales_info, product: available_product)

        get product_path(available_product)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when product is discontinued' do
      it 'redirects to products list' do
        discontinued_product = create(:product)
        create(:product_sales_info, :discontinued, product: discontinued_product)

        get product_path(discontinued_product)
        expect(response).to redirect_to(products_path)
      end
    end

    context 'when product is for future release' do
      it 'redirects to products list' do
        future_product = create(:product)
        create(:product_sales_info, effective_from: 1.day.from_now, product: future_product)

        get product_path(future_product)
        expect(response).to redirect_to(products_path)
      end
    end

    context 'when product does not exist' do
      it 'redirects to products list' do
        get product_path(id: 'invalid')
        expect(response).to redirect_to(products_path)
      end
    end
  end
end
