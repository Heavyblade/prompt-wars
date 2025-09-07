module TimeOff
  class AccrualPolicy
    VACATION_LIMIT_DAYS = 20

    def within_vacation_limit?(user:, new_request: nil)
      cutoff = Date.current - 365
      approved_vacation_days = TimeOffRequest.joins(:time_off_type)
        .where(user_id: user.id, status: :approved)
        .where("time_off_types.name LIKE ?", "vacation")
        .where("end_date >= ?", cutoff)
        .sum("(julianday(end_date) - julianday(start_date)) + 1")

      new_days = if new_request&.time_off_type&.name&.downcase == "vacation"
        (new_request.end_date - new_request.start_date).to_i + 1
      else
        0
      end

      (approved_vacation_days.to_i + new_days) <= VACATION_LIMIT_DAYS
    end
  end
end

