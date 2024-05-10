class Api::V1::RecaptchaController < Api::V1::BaseController
  skip_before_action :authenticate

  def verify
    return render_error I18n.t('errors.invalid_captcha') unless response_success?(params[:token])
    render_ok
  end

  private

  def response_success?(token)
    uri = URI 'https://www.google.com/recaptcha/api/siteverify'
    https = Net::HTTP.new uri.host, uri.port
    https.use_ssl = true
    verify_request = Net::HTTP::Post.new uri.path
    verify_request.set_form_data secret: ENV['RECAPTCHA_SECRET'], response: token
    response = https.request verify_request
    result = JSON.parse response.body
    result['success']
  end
end
