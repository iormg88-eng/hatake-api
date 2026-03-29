class GroupMember < ApplicationRecord
  belongs_to :user
  belongs_to :group

  ROLES = %w[admin member].freeze

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :group_id }
end
