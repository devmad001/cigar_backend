ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.default charset: 'utf-8'
ActionMailer::Base.default_url_options = { host: ENV['HOST'] || ENV['API_HOST'] }

begin
  ActionMailer::Base.smtp_settings = {
    address: 'smtp.sendgrid.net',
    domain: 'em398.hiscigar.com',
    port: 587,
    authentication: :plain,
    user_name: 'apikey',
    password: ENV['SENDGRID_API_KEY'],
    enable_starttls_auto: true,
  }
rescue

end
