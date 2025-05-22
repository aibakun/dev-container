require 'rails_helper'

RSpec.describe 'ProductSalesInfos', type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:product_sales_info) { create(:product_sales_info, product: product) }

  before do
    login(user, 'password')
    create(:permission, user: user, controller: 'product_sales_infos', action: 'index')
    create(:permission, user: user, controller: 'product_sales_infos', action: 'create')
    create(:permission, user: user, controller: 'product_sales_infos', action: 'new')
    create(:permission, user: user, controller: 'product_sales_infos', action: 'edit')
    create(:permission, user: user, controller: 'product_sales_infos', action: 'update')
  end

  describe 'GET /product_sales_infos' do
    it 'returns a 200 response' do
      get product_sales_infos_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /products/:product_id/product_sales_infos/new' do
    it 'returns a 200 response' do
      get new_product_product_sales_info_path(product)
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /products/:product_id/product_sales_infos' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          product_sales_info: {
            price: 1000,
            effective_from: Time.current,
            discontinued: false
          }
        }
      end

      it 'returns a 302 response' do
        post product_product_sales_infos_path(product), params: valid_params
        expect(response).to have_http_status(302)
      end

      it 'creates a new product sales info' do
        expect do
          post product_product_sales_infos_path(product), params: valid_params
        end.to change(ProductSalesInfo, :count).by(1)
      end

      it 'redirects to index page' do
        post product_product_sales_infos_path(product), params: valid_params
        expect(response).to redirect_to(product_sales_infos_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          product_sales_info: {
            price: nil,
            effective_from: nil,
            discontinued: false
          }
        }
      end

      it 'returns a 422 response' do
        post product_product_sales_infos_path(product), params: invalid_params
        expect(response).to have_http_status(422)
      end

      it 'does not create a product sales info' do
        expect do
          post product_product_sales_infos_path(product), params: invalid_params
        end.not_to change(ProductSalesInfo, :count)
      end
    end
  end

  describe 'GET /product_sales_infos/:id/edit' do
    it 'returns a 200 response' do
      get edit_product_sales_info_path(product_sales_info)
      expect(response).to have_http_status(200)
    end
  end

  describe 'PATCH /product_sales_infos/:id' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          product_sales_info: {
            price: 2000,
            effective_from: Time.current,
            discontinued: true
          }
        }
      end

      it 'returns a 302 response' do
        patch product_sales_info_path(product_sales_info), params: valid_params
        expect(response).to have_http_status(302)
      end

      it 'updates the product sales info' do
        patch product_sales_info_path(product_sales_info), params: valid_params
        product_sales_info.reload
        expect(product_sales_info.price).to eq 2000
      end

      it 'redirects to index page' do
        patch product_sales_info_path(product_sales_info), params: valid_params
        expect(response).to redirect_to(product_sales_infos_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          product_sales_info: {
            price: nil,
            effective_from: nil,
            discontinued: false
          }
        }
      end

      it 'returns a 422 response' do
        patch product_sales_info_path(product_sales_info), params: invalid_params
        expect(response).to have_http_status(422)
      end

      it 'does not update the product sales info' do
        original_price = product_sales_info.price
        patch product_sales_info_path(product_sales_info), params: invalid_params
        product_sales_info.reload
        expect(product_sales_info.price).to eq original_price
      end
    end
  end
end
