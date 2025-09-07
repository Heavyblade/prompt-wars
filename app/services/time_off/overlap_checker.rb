module TimeOff
  class OverlapChecker
    def overlap_exists?(user:, start_date:, end_date:, excluding_id: nil)
      scope = TimeOffRequest.where(user_id: user.id)
                             .where(status: [TimeOffRequest.statuses[:pending], TimeOffRequest.statuses[:approved]])
      scope = scope.where.not(id: excluding_id) if excluding_id
      scope.where("start_date <= ? AND end_date >= ?", end_date, start_date).exists?
    end
  end
end

