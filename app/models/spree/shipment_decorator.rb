module Spree
  Shipment.class_eval do
    # Determines the appropriate +state+ according to the following logic:
    #
    # pending    unless order is complete and +order.payment_state+ is +paid+
    # shipped    if already shipped (ie. does not change the state)
    # ready      all other cases
    def determine_state(order)
      return 'ready' if cash_on_delivery?
      return 'canceled' if order.canceled?
      return 'pending' unless order.can_ship?
      return 'pending' if inventory_units.any? &:backordered?
      return 'shipped' if state == 'shipped'
      order.paid? || Spree::Config[:auto_capture_on_dispatch] ? 'ready' : 'pending'
    end

    private

    def cash_on_delivery?
      order.payments.any? do |payment|
        payment.payment_method.respond_to?(:cash_on_delivery?)
      end
    end
  end
end
