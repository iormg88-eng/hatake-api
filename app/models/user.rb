class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  has_many :field_logs, dependent: :destroy

  validates :name, presence: true
end
