class ScraperController < ApplicationController

  def status
    @count = Article.count
    @count_by_status = Article.group(:queue_status).count
    @count_by_source = Article.group(:source).count
    @count_by_date = Article.group(:pub_date).count
    @completed_no_abstract_no_media = Article.completed.where("abstract is null").where("scan_src_url is null").count
    @completed_no_abstract_with_media = Article.completed.where("abstract is null").where("scan_src_url is not null").count
    @completed_with_media = Article.completed.where("scan_src_url is not null").count
    @completed_with_local_media = Article.completed.where("scan_local_filename is not null").count
  end

end
