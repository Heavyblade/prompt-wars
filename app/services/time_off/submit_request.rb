module TimeOff
  class SubmitRequest
    def call(user:, params:)
      request = user.time_off_requests.new(params)

      unless TimeOff::AccrualPolicy.new.within_vacation_limit?(user: user, new_request: request)
        request.errors.add(:base, "Vacation limit exceeded for the last 12 months")
        return request
      end

      request.save
      request
    end
  end
end

