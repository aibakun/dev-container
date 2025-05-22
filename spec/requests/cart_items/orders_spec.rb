RSpec.describe 'CartItems::Orders', type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let!(:product_sales_info) { create(:product_sales_info, product: product) }
  let(:cart) { instance_double(Cart) }

  before do
    login(user, 'password')
    create(:permission, user: user, controller: 'cart_items/orders', action: 'create')
    allow(Cart).to receive(:new).and_return(cart)
  end

  describe 'POST /cart_items/orders' do
    context 'when checkout is successful' do
      before do
        allow(cart).to receive(:checkout).and_return(true)
      end

      it 'clears cart and redirects to products path' do
        post cart_items_orders_path
        expect(session[:cart_items]).to be_nil
        expect(response).to redirect_to(products_path)
        expect(response).to have_http_status(:found)
      end
    end

    context 'when cart is empty' do
      let(:empty_cart) { instance_double(Cart) }

      before do
        allow(Cart).to receive(:new).and_return(empty_cart)
        allow(empty_cart).to receive(:checkout).and_raise(Cart::InvalidCartItemError)
      end

      it 'returns redirect status' do
        post cart_items_orders_path
        expect(response).to have_http_status(:found)
      end
    end

    context 'when checkout fails' do
      before do
        allow(cart).to receive(:checkout).and_return(false)
      end

      it 'redirects back to cart' do
        post cart_items_orders_path
        expect(response).to redirect_to(cart_path)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
