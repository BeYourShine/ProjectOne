class Micropost < ApplicationRecord
  belongs_to :user

  validates :content, presence: true,
    length: {maximum: Settings.model.micropost.conten.max_length}
  validates :user, presence: true
  validate :picture_size

  scope :recent, ->{order created_at: :desc}

  mount_uploader :picture, PictureUploader

  private

  def picture_size
    return unless picture.size > Settings.model.micropost.picture_size.max_size.megabytes
    errors.add :picture, I18n.t("microposts.model.picture_size.error")
  end
end
