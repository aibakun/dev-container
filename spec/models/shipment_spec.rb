require 'rails_helper'

RSpec.describe Shipment, type: :model do
  let(:order) { create(:order) }
  let(:shipment) { create(:shipment, order: order) }

  describe 'associations' do
    it 'belongs to an order' do
      expect(shipment.order).to eq(order)
    end
  end

  describe 'validations' do
    it 'requires an order' do
      shipment.order = nil
      expect(shipment).to be_invalid
    end

    it 'requires a status' do
      shipment.status = nil
      expect(shipment).to be_invalid
    end

    it 'requires a tracking number' do
      shipment.tracking_number = nil
      expect(shipment).to be_invalid
    end

    it 'requires a unique tracking number' do
      dup_shipment = build(:shipment, tracking_number: shipment.tracking_number)
      expect(dup_shipment).to be_invalid
    end
  end

  describe 'state transitions' do
    context 'when status is preparing' do
      it 'starts with preparing status' do
        expect(shipment).to be_preparing
      end

      it 'can transition to shipped' do
        expect(shipment).to be_preparing
        expect(shipment.ship).to be_truthy
        expect(shipment).to be_shipped
      end

      it 'cannot transition to in_transit' do
        expect(shipment).to be_preparing
        expect(shipment.begin_transit).to be_falsey
        expect(shipment).to be_preparing
      end

      it 'cannot transition to delivered' do
        expect(shipment).to be_preparing
        expect(shipment.mark_as_delivered).to be_falsey
        expect(shipment).to be_preparing
      end
    end

    context 'when status is shipped' do
      before { shipment.ship }

      it 'can transition to in_transit' do
        expect(shipment).to be_shipped
        expect(shipment.begin_transit).to be_truthy
        expect(shipment).to be_in_transit
      end

      it 'cannot transition back to preparing' do
        expect(shipment).to be_shipped
      end

      it 'cannot transition directly to delivered' do
        expect(shipment).to be_shipped
        expect(shipment.mark_as_delivered).to be_falsey
        expect(shipment).to be_shipped
      end
    end

    context 'when status is in_transit' do
      before do
        shipment.ship
        shipment.begin_transit
      end

      it 'can transition to delivered' do
        expect(shipment).to be_in_transit
        expect(shipment.mark_as_delivered).to be_truthy
        expect(shipment).to be_delivered
      end

      it 'cannot transition back to shipped' do
        expect(shipment).to be_in_transit
        expect(shipment.ship).to be_falsey
        expect(shipment).to be_in_transit
      end
    end

    context 'when status is delivered' do
      before do
        shipment.ship
        shipment.begin_transit
        shipment.mark_as_delivered
      end

      it 'cannot transition to any other state' do
        expect(shipment).to be_delivered
        expect(shipment.ship).to be_falsey
        expect(shipment.begin_transit).to be_falsey
        expect(shipment).to be_delivered
      end
    end
  end

  describe 'forced state transitions' do
    it 'raises error when forcing ship from non-preparing state' do
      shipment.ship
      expect { shipment.ship! }.to raise_error(Shipment::TransitionError)
    end

    it 'raises error when forcing transit from non-shipped state' do
      expect { shipment.begin_transit! }.to raise_error(Shipment::TransitionError)
    end

    it 'raises error when forcing delivery from non-transit state' do
      expect { shipment.mark_as_delivered! }.to raise_error(Shipment::TransitionError)
    end
  end

  describe 'next action' do
    it 'returns ship when preparing' do
      expect(shipment.next_action).to eq('ship')
    end

    it 'returns begin_transit when shipped' do
      shipment.ship
      expect(shipment.next_action).to eq('begin_transit')
    end

    it 'returns mark_as_delivered when in_transit' do
      shipment.ship
      shipment.begin_transit
      expect(shipment.next_action).to eq('mark_as_delivered')
    end

    it 'returns nil when delivered' do
      shipment.ship
      shipment.begin_transit
      shipment.mark_as_delivered
      expect(shipment.next_action).to be_nil
    end
  end

  describe 'process_event' do
    it 'processes ship event successfully' do
      expect(shipment).to be_preparing
      shipment.process_event('ship')
      expect(shipment).to be_shipped
    end

    it 'processes begin_transit event successfully' do
      shipment.ship
      expect(shipment).to be_shipped
      shipment.process_event('begin_transit')
      expect(shipment).to be_in_transit
    end

    it 'processes mark_as_delivered event successfully' do
      shipment.ship
      shipment.begin_transit
      expect(shipment).to be_in_transit
      shipment.process_event('mark_as_delivered')
      expect(shipment).to be_delivered
    end

    it 'raises error for invalid event' do
      expect { shipment.process_event('invalid_event') }.to raise_error(Shipment::TransitionError)
    end

    it 'raises error for inappropriate state transition' do
      expect { shipment.process_event('begin_transit') }.to raise_error(Shipment::TransitionError)
    end
  end
end
