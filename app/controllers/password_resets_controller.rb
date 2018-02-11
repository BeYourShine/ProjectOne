class PasswordResetsController < ApplicationController
  before_action :find_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    user = User.find_by email: params[:password_reset][:email].downcase
    if user
      send_mail_valid_user user
    else
      flash.now[:danger] = t "password_resets.controller.flash.not_found_email"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      user.errors.add password: t("password_resets.controller.error.pass_empty")
      render_edit
    elsif user.update_attributes user_params
      after_update_pass user
    else
      render_edit
    end
  end

  private

  attr_reader :user

  def after_update_pass user
    log_in user
    flash[:success] = t "password_resets.controller.flash.has_reset_pass"
    redirect_to user
  end

  def check_expiration
    return unless user.password_reset_expired?
    flash[:danger] = t "password_resets.controller.flash.pass_reset_expired"
    redirect_to new_password_reset_url
  end

  def render_edit
    render :edit
  end

  def redirect_root
    redirect_to root_url
  end

  def find_user
    return if (@user = User.find_by email: params[:email])
    flash[:danger] = t "password_resets.controller.flash.not_found_email"
    redirect_root
  end

  def send_mail_valid_user user
    reset_token = User.new_token
    user.create_reset_digest reset_token
    UserMailer.password_reset(user, reset_token).deliver_now
    flash[:info] = t "password_resets.controller.flash.intruction"
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def valid_user
    action_not_activate user unless user && user.activated?
    return if user.authenticated? :reset, params[:id]
    flash[:danger] = t "password_resets.controller.flash.not_authenticated"
    redirect_root
  end

  def action_not_activate user
    flash[:danger] = t "password_resets.controller.flash.not_activated"
    user.send_activation_email
    redirect_root
  end
end
