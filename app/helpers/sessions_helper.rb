module SessionsHelper
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by id: user_id
    elsif (cookie_id = cookies.signed[:user_id])
      user = User.find_by id: cookie_id
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def log_in user
    session[:user_id] = user.id
  end

  def logged_in?
    current_user != nil
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  def remember user
    @token = User.new_token
    @user_remember = user
    @user_remember.remember @token
    cookie_pernanet.signed[:user_id] = @user_remember.id
    cookie_pernanet[:remember_token] = @token
  end

  def redirect_back_or default
    redirect_to session[:forwarding_url] || default
    session.delete :forwarding_url
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  private

  def cookie_pernanet
    cookies.permanent
  end
end
