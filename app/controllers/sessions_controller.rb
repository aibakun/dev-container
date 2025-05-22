class SessionsController < ApplicationController
  layout 'login', only: %i[new create]
  skip_before_action :authenticate_user!
  skip_before_action :check_permission
  def new; end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = t('sessions.create.login')
      redirect_to root_path
    else
      flash.now[:alert] = t('sessions.new.invalid_email_or_password')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:cart_items] = nil
    session[:user_id] = nil
    flash[:notice] = t('sessions.destroy.logout')
    redirect_to login_path
  end
end
