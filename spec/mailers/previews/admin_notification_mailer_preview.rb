# Preview all emails at http://localhost:3000/rails/mailers/admin_notification_mailer
class AdminNotificationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/admin_notification_mailer/first_purchase_notification
  def first_purchase_notification
    AdminNotificationMailer.first_purchase_notification
  end
end
