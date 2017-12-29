class SessionsController < ApplicationController
  def new; end

  def create
    params_session = params[:session]
    user = User.find_by email: params_session[:email].downcase
    if user && user.authenticate(params_session[:password])
      login_user user
    else
      flash.now[:danger] = t "sessions.flash.invalid_login"
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

  def login_user user
    log_in user
    redirect_to user
  end
end
