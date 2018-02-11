class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_reader :remember_token

  has_many :active_relationships, class_name: "Relationship",
    foreign_key: "follower_id", inverse_of: :followed, dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
    foreign_key: "followed_id", inverse_of: :follower, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :microposts, dependent: :destroy

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

  def feed
    Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id).recent
  end

  def forget
    update_attributes remember_digest: nil
  end

  def remember
    @remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def create_reset_digest token
    update_attributes reset_digest: User.digest(token),
      reset_sent_at: Time.zone.now
  end

  def password_reset_expired?
    reset_sent_at < Settings.model.user.pass_reset_expired.hours.ago
  end

  def following? other_user
    following.include? other_user
  end

  def follow other_user
    active_relationships.create followed_id: other_user.id
  end

  def unfollow other_user
    following.delete other_user
  end

  def create_activation_digest token
    update_attributes activation_digest: User.digest(token)
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
