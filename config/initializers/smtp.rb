# frozen_string_literal: true

if Rails.env.staging? || Rails.env.production?
  unless defined?(SMTP_SETTINGS)
    SMTP_SETTINGS = {
      address: ENV['SMTP_ADDRESS'],
      port: ENV['SMTP_PORT'],
      user_name: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD'],
      authentication: :plain,
      tls: false,
      domain: ENV['SMTP_DOMAIN'],
      openssl_verify_mode: ENV['SMTP_VERIFY_MODE'] || 'none'
    }.freeze
  end

  Rails.application.config.action_mailer.smtp_settings = SMTP_SETTINGS
end
