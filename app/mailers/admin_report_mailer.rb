class AdminReportMailer < ApplicationMailer
  def daily_sales_report
    @report_data = params[:report_data]
    @report_date = params[:report_date]
    admin_emails = params[:admin_emails]

    mail(
      to: admin_emails,
      subject: "Reporte de Ventas del #{@report_date.strftime('%Y-%m-%d')}"
    )
  end
end