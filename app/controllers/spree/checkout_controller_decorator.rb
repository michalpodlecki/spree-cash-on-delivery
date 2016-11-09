Spree::CheckoutController.class_eval do

  before_action :pay_on_delivery, only: :update

  private

  def pay_on_delivery
    return unless params[:state] == 'payment'
    return if params[:order].blank? || params[:order][:payments_attributes].blank?

    pm_id = params[:order][:payments_attributes].first[:payment_method_id]
    payment_method = Spree::PaymentMethod.find(pm_id)

    payment_method.apply_adjustment(@order) if apply_adjustment?(payment_method)
  rescue => e
    @order.errors[:base] << "Something went wrong: #{e.try(:message)}"
    render :edit
  end

  def apply_adjustment?(payment_method)
    payment_method &&
      payment_method.kind_of?(Spree::PaymentMethod::CashOnDelivery) &&
      payment_method.respond_to?(:apply_adjustment)
  end
end
