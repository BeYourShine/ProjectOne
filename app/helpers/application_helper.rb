module ApplicationHelper
  def full_title page_title = ""
    @base_title = t "app.supt1"
    page_title == "" ? @base_title : page_title + " | " + @base_title
  end
end
