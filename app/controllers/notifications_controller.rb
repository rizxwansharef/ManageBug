class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def mark_as_read
        @user = User.find(params[:user_id])
        @notifications = @user.notifications.where(read: false)
        @notifications.each do |notification|
          notification.update(read: true)
    end
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end


