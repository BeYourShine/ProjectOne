class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("user_mailer.account_activation.subject_activation")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("user_mailer.account_activation.subject_reset_pass")
  end
end
