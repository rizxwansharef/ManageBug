class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, if: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  helper_method :manager?, :developer?,  :qa?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_back fallback_location: projects_path, alert: "You are not authorized to perform this action."
  end

  def not_found
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def manager?
    current_user&.manager?
  end

  def developer?
    current_user&.developer?
  end

  def qa?
    current_user&.qa?
  end

  def after_sign_in_path_for(resource)
    projects_path
  end

  def after_sign_up_path_for(resource)
    projects_path
  end

  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :role, :profile_picture ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :role, :profile_picture ])
  end
end
