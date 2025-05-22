class Shipment < ApplicationRecord
  class TransitionError < StandardError; end

  belongs_to :order

  enum status: {
    preparing: 0,
    shipped: 1,
    in_transit: 2,
    delivered: 3
  }

  validates :status, presence: true
  validates :tracking_number, presence: true, uniqueness: true

  def next_action
    case status
    when 'preparing'
      'ship'
    when 'shipped'
      'begin_transit'
    when 'in_transit'
      'mark_as_delivered'
    end
  end

  def process_event(event)
    case event
    when 'ship'
      ship!
    when 'begin_transit'
      begin_transit!
    when 'mark_as_delivered'
      mark_as_delivered!
    else
      raise TransitionError, "Invalid event: #{event}"
    end
  end

  def ship
    transition_to(:shipped) if preparing?
  end

  def ship!
    ship || raise(TransitionError, 'Cannot transition to shipped state unless preparing')
  end

  def begin_transit
    transition_to(:in_transit) if shipped?
  end

  def begin_transit!
    begin_transit || raise(TransitionError, 'Cannot transition to in_transit state unless shipped')
  end

  def mark_as_delivered
    transition_to(:delivered) if in_transit?
  end

  def mark_as_delivered!
    mark_as_delivered || raise(TransitionError, 'Cannot transition to delivered state unless in_transit')
  end

  private

  def transition_to(new_status)
    update(status: new_status)
  end
end
