module Api
  class InternalBaseController < Api::BaseController
    skip_before_action :authenticate_token
    before_action :authenticate_internal_request
    before_action :check_permission

    private

    def authenticate_internal_request
      render_error('Unauthorized', :unauthorized) if current_user.blank?
    end

    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def check_permission
      render_error('Permission denied', :forbidden) if !user_has_permission?
    end
  end
end
