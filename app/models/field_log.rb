class FieldLog < ApplicationRecord
  belongs_to :field
  belongs_to :user

  has_many_attached :photos

  validate :photos_count_within_limit
  validate :photos_are_images

  STATUSES = %w[good caution urgent].freeze
  TAGS = %w[bug disease water growth work machine].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :memo, length: { maximum: 120 }, allow_blank: true
  validate :tags_are_valid

  private

  def tags_are_valid
    return if tags.blank?
    invalid = tags - TAGS
    errors.add(:tags, "に無効な値が含まれています: #{invalid.join(', ')}") if invalid.any?
  end

  def photos_count_within_limit
    return unless photos.attached?
    errors.add(:photos, "は最大3枚までです") if photos.size > 3
  end

  def photos_are_images
    return unless photos.attached?
    photos.each do |photo|
      unless photo.blob.content_type.start_with?("image/")
        errors.add(:photos, "は画像ファイルのみ添付できます")
        break
      end
    end
  end
end
