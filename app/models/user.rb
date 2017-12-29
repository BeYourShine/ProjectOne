class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_reader :remember_token, :activation_token, :reset_token

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
  before_create :create_activation_digest

  scope :activate, ->(status){where activated: status}

  def activate
    update_attributes activated: true, activated_at: Time.zone.now
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest
    BCrypt::Password.new(digest).is_password? token
  end

  def current_user? user
    user == self
  end

  def forget
    update_attributes remember_digest: nil
  end

  def remember
    @remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    @reset_token = User.new_token
    update_attributes reset_digest: User.digest(reset_token),
      reset_sent_at: Time.zone.now
  end

  def password_reset_expired?
    reset_sent_at < Settings.model.user.pass_reset_expired.hours.ago
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
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

  def create_activation_digest
    @activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end

  def mail_downcase
    email.downcase!
  end
end
