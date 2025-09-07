class TimeOffRequest < ApplicationRecord
  belongs_to :user
  belongs_to :time_off_type
  has_one :approval, dependent: :destroy

  enum :status, {pending: 0, approved: 1, denied: 2}

  validates :start_date, :end_date, :time_off_type, presence: true
  validate :start_not_after_end
  validate :not_in_past
  validate :no_overlapping_requests

  scope :for_user, ->(user) { where(user_id: user.id) }

  private

  def start_not_after_end
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be on or after start date") if end_date < start_date
  end

  def not_in_past
    return if start_date.blank?
    errors.add(:start_date, "cannot be in the past") if start_date < Date.current
  end

  def no_overlapping_requests
    return if start_date.blank? || end_date.blank? || user.blank?
    if TimeOff::OverlapChecker.new.overlap_exists?(user: user, start_date: start_date, end_date: end_date, excluding_id: id)
      errors.add(:base, "Overlapping time-off request exists")
    end
  end
end

