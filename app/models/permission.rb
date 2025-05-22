class Permission < ApplicationRecord
  belongs_to :user

  validates :controller, presence: true, uniqueness: { scope: %i[user_id action] }
  validates :action, presence: true
  validates :user, presence: true
  validate :controller_must_be_valid
  validate :action_must_be_valid

  def self.available_controllers
    Rails.application.eager_load!

    (ApplicationController.descendants + Api::BaseController.descendants)
      .reject { |controller| controller == Api::InternalBaseController }
      .map do |controller|
        controller.name.delete_suffix('Controller')
                  .underscore
                  .gsub('::', '/')
      end
  end

  def self.available_actions(controller_name)
    Rails.application.eager_load!

    controller = (ApplicationController.descendants + Api::BaseController.descendants)
                 .reject { |controller| controller == Api::InternalBaseController }
                 .find do |controller|
      controller.name.delete_suffix('Controller')
                .underscore
                .gsub('::', '/') == controller_name
    end

    raise ArgumentError, "Controller not found: #{controller_name}" if controller.nil?

    (controller.action_methods - controller.superclass.action_methods).sort
  end

  private

  def controller_must_be_valid
    return if controller.blank?
    return if self.class.available_controllers.include?(controller)

    errors.add(:controller, :invalid_controller)
  end

  def action_must_be_valid
    return if controller.blank? || action.blank?
    return if self.class.available_actions(controller).include?(action)

    errors.add(:action, :invalid_action)
  end
end
