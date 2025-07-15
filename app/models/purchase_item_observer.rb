class PurchaseItemObserver < ActiveRecord::Observer
  def after_create(purchase_item)
    return unless purchase_item.purchasable_type == "Product"

    is_first_purchase = PurchaseItem.where(
      purchasable_id: purchase_item.purchasable_id,
      purchasable_type: "Product"
    ).count == 1

    if is_first_purchase
      FirstPurchaseNotifierJob.perform_async(purchase_item.purchasable_id)
    end

    product = Product.includes(:creator).find_by(id: purchase_item.purchasable_id)
    return unless product&.creator
    ReportPurchaseJob.perform_async(product.creator.id, product.id, purchase_item.id)
  end
end
