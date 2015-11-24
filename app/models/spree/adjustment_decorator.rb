Spree::Adjustment.class_eval do
  scope :payment_method, -> { where(source_type: 'Spree::Payment') }
end
