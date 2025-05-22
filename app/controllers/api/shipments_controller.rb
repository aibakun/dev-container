module Api
  class ShipmentsController < Api::InternalBaseController
    def update
      @shipment = Shipment.find(params[:id])
      event = params[:event]

      begin
        @shipment.process_event(event)
        render json: {
          status: 'success',
          shipment: shipment_response(@shipment)
        }
      rescue Shipment::TransitionError => e
        render_error(e.message, :unprocessable_entity)
      end
    end

    private

    def shipment_response(shipment)
      {
        id: shipment.id,
        status: shipment.status,
        status_text: I18n.t("shipment.status.#{shipment.status}")
      }
    end
  end
end
