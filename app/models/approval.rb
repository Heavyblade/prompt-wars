class Approval < ApplicationRecord
  belongs_to :time_off_request
  belongs_to :approver, class_name: "User"

  enum :status, {pending: 0, approved: 1, denied: 2}
end

