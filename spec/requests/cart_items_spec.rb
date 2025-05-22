RSpec.describe 'CartItems', type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let!(:product_sales_info) { create(:product_sales_info, product: product) }
  let(:cart) { instance_double(Cart) }

  before do
    login(user, 'password')
    create(:permission, user: user, controller: 'cart_items', action: 'create')
    create(:permission, user: user, controller: 'cart_items', action: 'update')
    create(:permission, user: user, controller: 'cart_items', action: 'destroy')
    allow(Cart).to receive(:new).and_return(cart)
  end

  describe 'POST /cart_items' do
    let(:params) { { product_id: product.id, quantity: 1 } }

    context 'when successful' do
      before do
        allow(cart).to receive(:add_item)
        allow(cart).to receive(:cart_items).and_return({})
      end

      it 'returns redirect status' do
        post cart_items_path, params: params
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when cart raises InvalidCartItemError' do
      before do
        allow(cart).to receive(:add_item).and_raise(Cart::InvalidCartItemError)
      end

      it 'returns redirect status' do
        post cart_items_path, params: params
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'PATCH /cart_items/:id' do
    let(:params) { { id: product.id, quantity: 2 } }

    context 'when successful' do
      before do
        allow(cart).to receive(:update_quantity)
        allow(cart).to receive(:cart_items).and_return({})
      end

      it 'returns redirect status' do
        patch cart_item_path(product), params: params
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when cart raises InvalidCartItemError' do
      before do
        allow(cart).to receive(:update_quantity).and_raise(Cart::InvalidCartItemError)
      end

      it 'returns redirect status' do
        patch cart_item_path(product), params: params
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'DELETE /cart_items/:id' do
    before do
      allow(cart).to receive(:remove_item)
      allow(cart).to receive(:cart_items).and_return({})
    end

    it 'returns redirect status' do
      delete cart_item_path(product)
      expect(response).to have_http_status(:redirect)
    end
  end
end
