Spree::Adjustment.class_eval do
  scope :payment_method, -> { where("source_type LIKE 'Spree::Payment%'") }
end
