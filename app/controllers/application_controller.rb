class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  before_action :set_locale

  def change_language
    cookies.permanent[:language] = params[:lang].to_sym
    redirect_back fallback_location: root_path
  end

  private

  attr_reader :lang

  def set_locale
    @lang = cookies[:language].to_sym if cookies[:language]
    I18n.locale =
      if I18n.available_locales.include? lang
        lang
      else
        I18n.default_locale
      end
  end
end
