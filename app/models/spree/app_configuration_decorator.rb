Spree::AppConfiguration.class_eval do
  preference :cash_on_delivery_charge, :decimal, :default => 5.2
end
