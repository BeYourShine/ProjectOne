class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_reader :remember_token

  validates :email, format: {with: VALID_EMAIL_REGEX},
    length: {maximum: Settings.model.user.email.max_length},
    presence: true,
    uniqueness: {case_sensitive: false}
  validates :name, length: {maximum: Settings.model.user.user_name.max_length},
    presence: true
  validates :password, allow_nil: true,
    length: {minimum: Settings.model.user.pass.min_length},
    presence: true

  has_secure_password

  before_save :mail_downcase

  def authenticated? remember_token
    return false unless remember_digest
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attributes remember_digest: nil
  end

  def remember token
    update_attributes remember_digest: User.digest(token)
  end

  class << self
    def digest string
      cost =
        if ActiveModel::SecurePassword.min_cost
          BCrypt::Engine::MIN_COST
        else
          BCrypt::Engine.cost
        end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  private

  def mail_downcase
    email.downcase!
  end
end
