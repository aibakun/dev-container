RSpec.describe Cart do
  let(:user) { create(:user) }
  let(:cart_items) { [] }
  let(:cart) { Cart.new(cart_items, user) }
  let(:product) { create(:product) }
  let!(:sales_info) { create(:product_sales_info, product: product) }

  describe '#items' do
    context 'when cart has items' do
      let(:cart_items) { [[product.id, 2]] }

      it 'returns cart items' do
        expect(cart.items.size).to eq(1)
        expect(cart.items.first.product).to eq(product)
        expect(cart.items.first.quantity).to eq(2)
      end
    end
  end

  describe '#add_item' do
    context 'with valid parameters' do
      it 'adds item to cart' do
        cart_item = cart.add_item(product, 2)
        expect(cart_item.product).to eq(product)
        expect(cart_item.quantity).to eq(2)
        expect(cart_items).to include([product.id, 2])
      end

      it 'updates quantity if product already exists' do
        cart.add_item(product, 2)
        cart.add_item(product, 3)
        expect(cart_items).to include([product.id, 5])
      end
    end

    context 'with invalid parameters' do
      it 'raises InvalidCartItemError for invalid quantity' do
        expect do
          cart.add_item(product, 0)
        end.to raise_error(Cart::InvalidCartItemError)
        expect(cart_items).not_to include([product.id, 0])
      end
    end
  end

  describe '#update_quantity' do
    context 'with existing item' do
      let(:cart_items) { [[product.id, 2]] }

      context 'with valid quantity' do
        it 'updates the quantity' do
          cart.update_quantity(product, 3)
          expect(cart_items).to include([product.id, 3])
        end
      end

      context 'with invalid quantity' do
        it 'removes the item when quantity is zero' do
          cart.update_quantity(product, 0)
          expect(cart_items).not_to include([product.id, 2])
        end

        it 'raises InvalidCartItemError for negative quantity' do
          expect do
            cart.update_quantity(product, -1)
          end.to raise_error(Cart::InvalidCartItemError)
        end
      end
    end
  end

  describe '#remove_item' do
    context 'with existing item' do
      let(:cart_items) { [[product.id, 2]] }

      it 'removes the item from cart' do
        cart.remove_item(product)
        expect(cart_items).to be_empty
      end
    end
  end

  describe '#clear' do
    context 'with items in cart' do
      let(:cart_items) { [[product.id, 2]] }

      it 'removes all items from cart' do
        cart.clear
        expect(cart_items).to be_empty
      end
    end
  end

  describe '#checkout' do
    context 'with items in cart' do
      let(:cart_items) { [[product.id, 2]] }

      it 'creates an order with items' do
        expect do
          @order = cart.checkout
        end.to change(Order, :count).by(1)
                                    .and change(OrderItem, :count).by(1)

        expect(@order).to be_present
        expect(@order).to be_persisted
        expect(@order.order_items.count).to eq(1)

        order_item = @order.order_items.first
        expect(order_item.product_sales_info).to eq(sales_info)
        expect(order_item.quantity).to eq(2)
      end

      it 'clears the cart after successful checkout' do
        cart.checkout
        expect(cart_items).to be_empty
      end
    end

    context 'with empty cart' do
      it 'returns false' do
        expect(cart.checkout).to be false
      end

      it 'does not create an order' do
        expect { cart.checkout }.not_to change(Order, :count)
      end
    end

    context 'when checkout fails' do
      let(:cart_items) { [[product.id, 2]] }

      before do
        allow_any_instance_of(Order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Order.new))
      end

      it 'returns false and keeps cart items' do
        expect(cart.checkout).to be false
        expect(cart_items).not_to be_empty
      end

      it 'does not create any records' do
        expect { cart.checkout }.not_to(change { Order.count })
        expect { cart.checkout }.not_to(change { OrderItem.count })
      end
    end
  end
end
