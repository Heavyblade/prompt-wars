module TimeOff
  class Decision
    def approve!(request:, approver:)
      ApplicationRecord.transaction do
        request.update!(status: :approved)
        approval = request.approval || request.build_approval
        approval.update!(approver: approver, status: :approved, decided_at: Time.current)
      end
      request
    end

    def deny!(request:, approver:)
      ApplicationRecord.transaction do
        request.update!(status: :denied)
        approval = request.approval || request.build_approval
        approval.update!(approver: approver, status: :denied, decided_at: Time.current)
      end
      request
    end
  end
end

