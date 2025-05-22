class PermissionsController < ApplicationController
  def index
    @permissions = Permission.preload(:user).all
  end

  def new
    @permission = Permission.new
    @users = User.all
    @available_controllers = Permission.available_controllers
    @available_actions = @available_controllers.index_with do |controller|
      Permission.available_actions(controller)
    end
  end

  def create
    @permission = Permission.new(permission_params)
    if @permission.save
      redirect_to permissions_path, notice: t('permissions.messages.created')
    else
      @users = User.all
      @available_controllers = Permission.available_controllers
      @available_actions = @available_controllers.index_with { |controller| Permission.available_actions(controller) }
      render :new
    end
  end

  def edit
    @permission = Permission.find(params[:id])
    @users = User.all
    @available_controllers = Permission.available_controllers
    @available_actions = @available_controllers.index_with { |controller| Permission.available_actions(controller) }
  end

  def update
    @permission = Permission.find(params[:id])
    if @permission.update(permission_params)
      redirect_to permissions_path, notice: t('permissions.messages.updated')
    else
      @users = User.all
      @available_controllers = Permission.available_controllers
      @available_actions = @available_controllers.index_with { |controller| Permission.available_actions(controller) }
      render :edit
    end
  end

  def destroy
    Permission.find(params[:id]).destroy!
    redirect_to permissions_path, notice: t('permissions.messages.destroyed')
  end

  private

  def permission_params
    params.require(:permission).permit(:user_id, :controller, :action)
  end
end
