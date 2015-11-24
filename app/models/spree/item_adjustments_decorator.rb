# Manage (recalculate) item (LineItem or Shipment) adjustments
Spree::ItemAdjustments.class_eval do
  # FIXME: callbacks inherited?
  # define_callbacks :promo_adjustments, :tax_adjustments, :payment_method_adjustments
  define_callbacks :payment_method_adjustments

  def update_adjustments
    # Promotion adjustments must be applied first, then tax adjustments.
    # This fits the criteria for VAT tax as outlined here:
    # http://www.hmrc.gov.uk/vat/managing/charging/discounts-etc.htm#1
    #
    # It also fits the criteria for sales tax as outlined here:
    # http://www.boe.ca.gov/formspubs/pub113/
    #
    # Tax adjustments come in not one but *two* exciting flavours:
    # Included & additional

    # Included tax adjustments are those which are included in the price.
    # These ones should not affect the eventual total price.
    #
    # Additional tax adjustments are the opposite, affecting the final total.
    payment_method_fees_total = 0
    run_callbacks :payment_method_adjustments do
      payment_method_fees_total = adjustments.payment_method.reload.map do |adjustment|
        adjustment.update!(@item)
      end.compact.sum
    end

    promo_total = 0
    run_callbacks :promo_adjustments do
      promotion_total = adjustments.promotion.reload.map do |adjustment|
        adjustment.update!(@item)
      end.compact.sum

      unless promotion_total == 0
        choose_best_promotion_adjustment
      end
      promo_total = best_promotion_adjustment.try(:amount).to_f
    end

    included_tax_total = 0
    additional_tax_total = 0
    run_callbacks :tax_adjustments do
      tax = (item.respond_to?(:all_adjustments) ? item.all_adjustments : item.adjustments).tax
      included_tax_total = tax.is_included.reload.map(&:update!).compact.sum
      additional_tax_total = tax.additional.reload.map(&:update!).compact.sum
    end

    item.update_columns(
      :promo_total => promo_total,
      :included_tax_total => included_tax_total,
      :additional_tax_total => additional_tax_total,
      :adjustment_total => promo_total + additional_tax_total + payment_method_fees_total,
      :updated_at => Time.now,
    )
  end
end
