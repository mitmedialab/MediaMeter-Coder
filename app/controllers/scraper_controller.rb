class ScraperController < ApplicationController

  def status
    @count_by_status = Article.group(:queue_status).count
    @count_by_source = Article.group(:source).count
    @count_by_date = Article.group(:pub_date).count
  end

end
