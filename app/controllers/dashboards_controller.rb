class DashboardsController < ApplicationController
  def show
    if manager?
      render :manager_dashboard
  
    elsif developer?
      render :developer_dashboard
  
    elsif qa?
      render :qa_dashboard
    end
  end
end
