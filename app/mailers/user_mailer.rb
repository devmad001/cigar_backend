class UserMailer < ApplicationMailer
  layout 'mailer'

  def successful_registration(user)
    return if user&.email.blank?
    @user = user
    mail(from: ENV['EMAIL_FROM'], to: @user.email, subject: 'Welcome to Cigar Finder!')
  end

  def reset_password(token, user)
    return if user&.email.blank?
    @token = token
    @user = user
    mail(from: ENV['EMAIL_FROM'], to: @user.email, subject: 'Reset password')
  end
end
