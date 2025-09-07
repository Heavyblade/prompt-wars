class TimeOffType < ApplicationRecord
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  scope :active, -> { where(active: true) }
end

