# app/jobs/daily_sales_report_job.rb
class DailySalesReportJob
  include Sidekiq::Job
  sidekiq_options retry: 3

  def perform
    yesterday = Date.yesterday
    date_range = yesterday.beginning_of_day..yesterday.end_of_day

    # 2. Consultar los items de compra de productos en ese rango
    # Agrupamos por producto y sumamos la cantidad y el precio total.
    sales_data = PurchaseItem
      .for_products
      .where(created_at: date_range)
      .joins(:product)
      .group("products.name")
      .select(
        "products.name",
        "SUM(purchase_items.quantity) as total_quantity",
        "SUM(purchase_items.total_price) as total_revenue"
      )

    return if sales_data.empty?

    admin_emails = Admin.pluck(:email)
    return if admin_emails.empty?

    AdminReportMailer.with(
      report_data: sales_data,
      report_date: yesterday,
      admin_emails: admin_emails
    ).daily_sales_report.deliver_later
  end
end
