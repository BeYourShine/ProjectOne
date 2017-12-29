class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      active_user user
    else
      flash[:danger] = t "account_activation.control.active_user.flash_inactive"
      redirect_to root_url
    end
  end

  private

  def active_user user
    user.activate
    log_in user
    flash[:success] = t "account_activation.control.active_user.flash_activate"
    redirect_to user
  end
end
