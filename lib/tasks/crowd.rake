require 'crowd_flower'

namespace :crowd do
	
	desc "Import and export for CrowdFlower"

  # run this like so:
  # rake crowd:import[sports,../crowdflower-round-2/a77851.csv,is_this_article_about_sports,is_this_article_about_sports:confidence] --trace
  task :import, [:answer_type, :file, :answer_col, :confidence_col] => [:environment] do |t, args|
    Rails.logger.info "Starting to import --------------------------------"
    Rails.logger.info " answer_type = #{args.answer_type}"
    Rails.logger.info " file = #{args.file}"
    Rails.logger.info " answer_col = #{args.answer_col}"
    Rails.logger.info " confidence_col = #{args.confidence_col}"
    CrowdFlower::import(args.answer_type, args.file, args.answer_col, args.confidence_col)
  end

  # run this like so:
  # rake crowd:export[sports,tmp] --trace 
  task :export, [:answer_type,:dir] => [:environment] do |t,args|
    Rails.logger.info "Starting to export --------------------------------"
    now = Time.now
    filename = args.answer_type + "_" + "articles" + "_" + now.year.to_s + now.month.to_s + now.day.to_s + "_" + now.hour.to_s + now.min.to_s + now.sec.to_s + ".csv"
    filepath = File.join(args.dir, filename )
    Rails.logger.info " to #{filepath}"
    CrowdFlower::export(args.answer_type, filepath)
  end

end