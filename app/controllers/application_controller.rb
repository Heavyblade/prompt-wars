class ApplicationController < ActionController::Base
  include Clearance::Controller
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_role?, :manager_of?

  def current_role?(role)
    current_user&.role == role.to_s
  end

  def require_admin!
    unless current_user&.admin?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Not authorized" }
        format.json { head :forbidden }
      end
    end
  end

  def require_manager_or_admin!
    unless current_user&.manager? || current_user&.admin?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Not authorized" }
        format.json { head :forbidden }
      end
    end
  end

  def manager_of?(user)
    return false unless current_user&.manager? || current_user&.admin?
    return true if current_user&.admin?
    user.manager_id == current_user.id
  end
end
