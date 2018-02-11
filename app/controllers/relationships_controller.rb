class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find_by id: params[:followed_id]
    current_user.follow user
    after_follow user
  end

  def destroy
    @user = Relationship.find_by(id: params[:id]).followed
    current_user.unfollow user
    after_unfollow user
  end

  private

  attr_reader :user

  def after_follow user
    respond_to do |format|
      format.html{redirect_to user}
      format.js
    end
  end

  def after_unfollow user
    respond_to do |format|
      format.html{redirect_to user}
      format.js
    end
  end
end
