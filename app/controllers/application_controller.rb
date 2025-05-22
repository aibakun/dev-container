class ApplicationController < ActionController::Base
  helper_method :current_user
  before_action :authenticate_user!
  before_action :check_permission

  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    redirect_to login_path unless current_user
  end

  def render_404
    render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
  end

  def handle_validation_error(error)
    Rails.logger.info "Validation failed: #{error.message}"
    template = action_name == 'create' ? :new : :edit
    render "#{template}", status: :unprocessable_entity
  end

  def handle_standard_error(error)
    Rails.logger.error "Error in #{controller_name}##{action_name}: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
    render file: Rails.root.join('public', '500.html'), status: :internal_server_error, layout: false
  end

  def check_permission
    return if user_has_permission?

    Rails.logger.warn "Permission denied for user #{current_user.id} on #{params[:controller]}##{params[:action]}"
    render file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false
  end

  def user_has_permission?
    Permission.where(user_id: current_user.id)
              .where("controller = ? OR controller = '*'", params[:controller])
              .where("action = ? OR action = '*'", params[:action])
              .exists?
  end
end
