RSpec.describe 'Orders', type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:product_sales_info) { create(:product_sales_info, product: product) }

  before do
    login(user, 'password')
    create(:permission, user: user, controller: 'orders', action: 'index')
    create(:permission, user: user, controller: 'orders', action: 'show')
    create(:permission, user: user, controller: 'orders', action: 'new')
    create(:permission, user: user, controller: 'orders', action: 'create')
  end

  describe 'GET /orders' do
    context 'when user has orders' do
      let!(:order) { create(:order, :with_items, user: user) }

      it 'returns a successful response' do
        get orders_path
        expect(response).to have_http_status(200)
      end

      it 'displays order status' do
        get orders_path
        expect(response.body).to include('完了')
      end

      it 'displays order operations' do
        get orders_path
        expect(response.body).to include('詳細')
        expect(response.body).to include('キャンセルする')
      end
    end

    context 'when user has no orders' do
      it 'returns a successful response' do
        get orders_path
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /orders/:id' do
    let(:order) { create(:order, :with_items, user: user) }

    context 'when order exists' do
      it 'returns a successful response' do
        get order_path(order)
        expect(response).to have_http_status(200)
      end

      it 'displays order details' do
        get order_path(order)
        expect(response.body).to include(order.created_at.strftime('%Y/%m/%d %H:%M'))
      end
    end

    context 'when order does not exist' do
      it 'returns not found status' do
        get order_path(id: 0)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'GET /orders/new' do
    it 'returns a successful response' do
      get new_order_path
      expect(response).to have_http_status(200)
    end

    it 'displays order form' do
      get new_order_path
      expect(response.body).to include('注文')
    end
  end

  describe 'POST /orders' do
    let(:valid_params) do
      {
        order: {
          order_date: Time.current,
          product_sales_info_ids: { '0' => product_sales_info.id },
          quantities: { '0' => '1' }
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new order' do
        expect do
          post orders_path, params: valid_params
        end.to change(Order, :count).by(1)
      end

      it 'creates order items' do
        expect do
          post orders_path, params: valid_params
        end.to change(OrderItem, :count).by(1)
      end

      it 'creates shipment information' do
        expect do
          post orders_path, params: valid_params
        end.to change(Shipment, :count).by(1)
      end

      it 'sets current user as order user' do
        post orders_path, params: valid_params
        expect(Order.last.user).to eq(user)
      end

      it 'redirects to the order' do
        post orders_path, params: valid_params
        expect(response).to redirect_to(order_path(Order.last))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          order: {
            order_date: Time.current,
            product_sales_info_ids: { '0' => '' },
            quantities: { '0' => '' }
          }
        }
      end

      it 'does not create an order' do
        expect do
          post orders_path, params: invalid_params
        end.not_to change(Order, :count)
      end

      it 'does not create order items' do
        expect do
          post orders_path, params: invalid_params
        end.not_to change(OrderItem, :count)
      end

      it 'does not create shipment' do
        expect do
          post orders_path, params: invalid_params
        end.not_to change(Shipment, :count)
      end

      it 'returns unprocessable entity status' do
        post orders_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
