class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: %i(destroy)

  def create
    @micropost = current_user.microposts.build micropost_params
    if micropost.save
      flash[:success] = t "microposts.controller.flash.create_micropost"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate page: params[:page]
      render "static_pages/home"
    end
  end

  def destroy
    micropost.destroy
    flash[:success] = t "microposts.controller.flash.delete_micropost"
    redirect_back fallback_location: root_url
  end

  private

  attr_reader :micropost

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    redirect_to root_url unless micropost
  end

  def micropost_params
    params.require(:micropost).permit :content, :picture
  end
end
