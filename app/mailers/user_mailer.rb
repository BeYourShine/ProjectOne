class UserMailer < ApplicationMailer
  def account_activation user, activation_token
    @user = user
    @activation_token = activation_token
    mail to: user.email, subject: t("user_mailer.account_activation.subject_activation")
  end

  def password_reset user, reset_token
    @user = user
    @reset_token = reset_token
    mail to: user.email, subject: t("user_mailer.account_activation.subject_reset_pass")
  end
end
