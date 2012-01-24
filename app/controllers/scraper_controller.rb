class ScraperController < ApplicationController

  def status
    @count = Article.count
    @count_by_status = Article.group(:queue_status).count
    @count_by_source = Article.group(:source).count
    @count_by_date = Article.group(:pub_date).count
    @completed_but_no_abstract = Article.where(:queue_status=>'complete').where("abstract is null").count
    @count_with_media = Article.where("scan_src_url is not null").count
    @count_with_local_media = Article.where("scan_local_filename is not null").count
  end

end
