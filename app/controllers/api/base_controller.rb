module Api
  class BaseController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error

    before_action :authenticate_token
    before_action :check_permission

    private

    def current_user
      @current_user ||= @api_token.user
    end

    def authenticate_token
      authenticate_with_http_token do |token, _options|
        @api_token = ApiToken.find_by(token: token)
        return if @api_token && @api_token.authenticate(token)
      end

      render_error('Invalid authentication token', :unauthorized)
    end

    def check_permission
      return if user_has_permission?

      Rails.logger.warn "API permission denied for user #{current_user&.id} on #{controller_name}##{action_name}"
      render_error('Permission denied', :forbidden)
    end

    def user_has_permission?
      current_user && Permission.where(user_id: current_user.id)
                                .where(controller: "api/#{controller_name}")
                                .where(action: action_name)
                                .exists?
    end

    def render_404
      render_error('Not Found', :not_found)
    end

    def handle_validation_error(error)
      render_error(error.record.errors.full_messages, :unprocessable_entity)
    end

    def handle_standard_error(error)
      Rails.logger.error "API Error in #{controller_name}##{action_name}: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      render_error('Internal Server Error', :internal_server_error)
    end

    def render_error(message, status)
      render json: {
        status: status,
        error: message,
        timestamp: Time.current
      }, status: status
    end
  end
end
