class UsersController < ApplicationController
  before_action :find_user, only: %i(show edit update destroy following
                                     followers)
  before_action :logged_in_user, only: %i(destroy edit index update)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @users = User.activate(true).paginate page: params[:page],
      per_page: Settings.controller.users.user_per_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if user.save
      after_save user
    else
      render :new
    end
  end

  def show
    redirect_to root_path && return unless user.activated?
    @microposts = user.microposts.paginate page: params[:page]
  end

  def edit; end

  def update
    if user.update_attributes user_params
      flash[:success] = t "users.flash.success_update"
      redirect_to user
    else
      render :edit
    end
  end

  def destroy
    user.destroy
    flash[:success] = t "users.flash.user_delete"
    redirect_to users_url
  end

  def following
    @title = t "users.controller.following.title"
    @users = user.following.paginate page: params[:page]
    render "show_follow"
  end

  def followers
    @title = t "users.controller.followers.title"
    @users = user.followers.paginate page: params[:page]
    render "show_follow"
  end

  private

  attr_reader :user

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def after_save user
    activation_token = User.new_token
    user.create_activation_digest activation_token
    UserMailer.account_activation(user, activation_token).deliver_now
    flash[:info] = t "users.flash.check_mail"
    redirect_to root_url
  end

  def correct_user
    return if user.current_user? current_user
    flash[:danger] = t "users.flash.unable_edit"
    redirect_to root_url
  end

  def find_user
    return if (@user = User.find_by id: params[:id])
    return if user.activated?
    flash[:danger] = t "users.flash.no_user"
    redirect_to root_path
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "users.flash.unable_edit"
    redirect_to login_url
  end

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end
end
