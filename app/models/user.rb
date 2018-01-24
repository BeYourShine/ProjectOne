class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, format: {with: VALID_EMAIL_REGEX},
    length: {maximum: Settings.model.user.email.max_length},
    presence: true,
    uniqueness: {case_sensitive: false}
  validates :name, length: {maximum: Settings.model.user.user_name.max_length},
    presence: true
  validates :password, length: {minimum: Settings.model.user.pass.min_length},
    presence: true

  has_secure_password

  before_save :mail_downcase

  private

  def mail_downcase
    email.downcase!
  end
end
