class RegistrationsController < Devise::RegistrationsController
  def role
    sign_out(current_user) if user_signed_in?
  end

  def new
    @selected_role = params[:role]
    super
  end

  def create
    @selected_role = params[:user][:role]
    super
  end
end
