class ApiToken < ApplicationRecord
  belongs_to :user

  has_secure_token

  def authenticate(token)
    return false if token.nil?

    ActiveSupport::SecurityUtils.secure_compare(self.token, token)
  end
end
