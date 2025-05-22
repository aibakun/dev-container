require 'rails_helper'

RSpec.describe ShipmentFactory do
  describe '.create' do
    it 'creates a new shipment with the correct attributes' do
      order = create(:order)

      shipment = ShipmentFactory.create(order)

      expect(shipment).to be_a(Shipment)
      expect(shipment.order).to eq(order)
      expect(shipment.status).to eq("preparing")
    end
  end

  describe '.generate_tracking_number' do
    it 'generates a tracking number in the correct format' do
      tracking_number = ShipmentFactory.generate_tracking_number
      expect(tracking_number).to match(/^[0-9A-F]{16}$/)
    end

    it 'generates unique tracking numbers' do
      tracking_number1 = ShipmentFactory.generate_tracking_number
      tracking_number2 = ShipmentFactory.generate_tracking_number
      expect(tracking_number1).not_to eq(tracking_number2)
    end
  end
end
