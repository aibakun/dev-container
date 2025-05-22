class ShipmentFactory
  def self.create(order)
    Shipment.new(
      order: order,
      status: :preparing,
      tracking_number: generate_tracking_number
    )
  end

  def self.generate_tracking_number
    SecureRandom.hex(8).upcase
  end
end
