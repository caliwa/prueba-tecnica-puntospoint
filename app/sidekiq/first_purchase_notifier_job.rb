class FirstPurchaseNotifierJob
  include Sidekiq::Job
  sidekiq_options retry: 3

  def perform(product_id)
    product = Product.find_by(id: product_id)
    return unless product

    creator = product.creator

    admin_ids = Admin.pluck(:id)

    return if admin_ids.empty? || creator.nil?

    AdminNotificationMailer.with(
      product: product,
      creator: creator,
      admin_ids: admin_ids
    ).first_purchase_notification.deliver_later
  end
end
