class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

 def mark_all_as_read
    current_user.notifications.update_all(read: true)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
