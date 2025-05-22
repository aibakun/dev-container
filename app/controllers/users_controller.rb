class UsersController < ApplicationController
  def index
    @page = [params[:page].to_i, 1].max
    per_page = 10
    @users = User.page(@page, per_page)
    @total_pages = User.total_pages(per_page)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @profile = @user.build_profile
  end

  def edit
    @user = User.find(params[:id])
    @profile = @user.profile || @user.build_profile
  end

  def create
    @user = User.new(user_params)
    @profile = @user.build_profile(profile_params)

    ActiveRecord::Base.transaction do
      @user.save! && @profile.save!
    end

    redirect_to @user
  end

  def update
    @user = User.find(params[:id])
    @profile = @user.profile || @user.build_profile

    ActiveRecord::Base.transaction do
      @user.update!(user_params) && @profile.update!(profile_params)
    end

    redirect_to @user
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :occupation)
  end

  def profile_params
    params.fetch(:profile, {}).permit(:biography)
  end
end
