module Spree
  CheckoutController.class_eval do
    before_action :ensure_no_payment_adjustment_in_cart

    def ensure_no_payment_adjustment_in_cart
      return unless @order.state == 'payment'
      @order.adjustments.payment_method.destroy_all
    end
  end
end
