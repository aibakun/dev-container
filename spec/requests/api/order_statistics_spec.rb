require 'rails_helper'

RSpec.describe 'Api::OrderStatistics', type: :request do
  let(:user) { create(:user) }
  let(:sales_info) { create(:product_sales_info, price: 1000) }

  before do
    create(:permission, user: user, controller: 'api/order_statistics', action: 'index')
    login(user, 'password')

    order = create(:order, user: user)
    order.order_items.clear
    order.order_items.create!(product_sales_info: sales_info, quantity: 1)
  end

  it 'returns success with statistics data' do
    get api_order_statistics_path
    expect(response).to have_http_status(:success)

    json = JSON.parse(response.body)
    expect(json['total_orders']).to eq(1)
    expect(json['monthly_statistics']).to be_present
    expect(json['product_statistics']).to be_present
  end
end
