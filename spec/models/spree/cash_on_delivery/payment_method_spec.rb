require 'spec_helper'

describe Spree::PaymentMethod::CashOnDelivery do
  context "capture" do
    before(:each) do
      @order = Factory(:order_with_totals)
      @order.payments = []
      @order.payments.build(:amount => @order.total)
    end
  end
end
