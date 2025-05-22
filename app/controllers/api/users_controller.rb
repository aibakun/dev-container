module Api
  class UsersController < BaseController
    def index
      render json: User.all
    end
  end
end
