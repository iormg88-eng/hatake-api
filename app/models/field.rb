class Field < ApplicationRecord
  belongs_to :group
  has_many :field_logs, dependent: :destroy

  validates :name, presence: true
end
