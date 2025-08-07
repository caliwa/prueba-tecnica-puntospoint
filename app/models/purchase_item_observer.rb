class PurchaseItemObserver < ActiveRecord::Observer
  def after_create(purchase_item)
    return unless purchase_item.purchasable_type == "Product"
    # Thread-safe approach
    begin
      FirstPurchaseNotification.find_or_create_by!(
        product_id: purchase_item.purchasable_id
      ) do |notification|
        FirstPurchaseNotifierJob.perform_async(purchase_item.purchasable_id)

        product = Product.includes(:creator).find_by(id: purchase_item.purchasable_id)
        return unless product&.creator
        ReportPurchaseJob.perform_async(product.creator.id, product.id, purchase_item.id)
    end
    rescue ActiveRecord::RecordNotUnique
      # Ya se procesó por otro thread
    end
  end
end
