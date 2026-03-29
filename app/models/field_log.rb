class FieldLog < ApplicationRecord
  belongs_to :field
  belongs_to :user

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
end
