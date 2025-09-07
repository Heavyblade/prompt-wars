module TimeOffRequestsHelper
  def status_badge(status)
    color = case status.to_s
            when "approved" then "bg-green-600"
            when "denied" then "bg-red-600"
            else "bg-yellow-600"
            end
    content_tag :span, status.to_s.humanize, class: "inline-block text-xs px-2 py-1 rounded text-white #{color}"
  end
end

