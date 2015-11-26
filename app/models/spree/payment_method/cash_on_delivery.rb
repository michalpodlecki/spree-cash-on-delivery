module Spree
  class PaymentMethod::CashOnDelivery < Spree::PaymentMethod

    preference :fee, :string

    def compute_amount(item=nil)
      preferred_fee.to_f
    end

    def payment_profiles_supported?
      true # we want to show the confirm step.
    end

    def post_create(payment)
      payment.order.adjustments.payment_method.destroy_all
      payment.order.adjustments.create(
        amount: compute_amount,
        source: self,
        order: payment.order,
        label: I18n.t(:shipping_and_handling)
      )
    end

    def update_adjustment(adjustment, src)
      adjustment.update_attribute_without_callbacks(:amount, compute_amount)
    end


    def authorize(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def capture(payment, source, gateway_options)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def void(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def actions
      %w{capture void}
    end

    def can_capture?(payment)
      payment.state == 'credit'
    end

    def can_void?(payment)
      payment.state != 'void'
    end

    def source_required?
      false
    end

    #def provider_class
    #  self.class
    #end

    def payment_source_class
      nil
    end

    def method_type
      'cash_on_delivery'
    end

    def available?
      active and config_valid?
    end

    def config_valid?
      preferred_fee.present?
    end
  end
end
