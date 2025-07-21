cron_jobs = [
  {
    name:  'Daily Sales Report - cada día a las 5:00 AM',
    class: 'DailySalesReportJob',
    cron:  '0 5 * * *' #5:00 AM
  }
]

if Sidekiq.server?
  Sidekiq::Cron::Job.load_from_array!(cron_jobs)
end
