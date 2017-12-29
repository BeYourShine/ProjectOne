module ApplicationHelper
  def full_title page_title = ""
    @base_title = I18n.t "app.rails"
    page_title == "" ? @base_title : page_title + " | " + @base_title
  end
end
