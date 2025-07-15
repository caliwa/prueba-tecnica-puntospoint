class AdminNotificationMailer < ApplicationMailer
  def first_purchase_notification
    @product = params[:product]
    @creator = params[:creator]
    admin_ids = params[:admin_ids]

    cc_admins_emails = User.where(id: admin_ids)
                             .where.not(id: @creator.id)
                             .pluck(:email)

    mail(
      to: @creator.email,
      cc: cc_admins_emails,
      subject: "¡Primera venta! El producto '#{@product.name}' ha sido comprado"
    )
  end
end
