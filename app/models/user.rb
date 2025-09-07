class User < ApplicationRecord
  include Clearance::User

  enum :role, {employee: 0, manager: 1, admin: 2}

  belongs_to :department, optional: true
  belongs_to :manager, class_name: "User", optional: true

  has_many :direct_reports, class_name: "User", foreign_key: :manager_id, dependent: :nullify
  has_many :time_off_requests, dependent: :destroy

  def full_name
    [first_name, last_name].compact.join(" ")
  end
end
