Spree::Order.class_eval do
  state_machine.before_transition to: [ :confirm, :complete ] do |order|
    order.update!
  end
end
