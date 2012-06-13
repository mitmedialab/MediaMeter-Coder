require 'crowd_flower'

namespace :crowd do
	
	desc "Import and export for CrowdFlower"
  
  # run this like so:
  # rake crowd:export_all_sets[sports,tmp] --trace 
  task :export_all_sets, [:answer_type,:dir] => [:environment] do |t,args|
    Rails.logger.info "Starting to export --------------------------------"
    timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    filename = args.answer_type + "_" + "articles" + "_" + timestamp + ".csv"
    filepath = File.join(args.dir, filename )
    Rails.logger.info " to #{filepath}"
    CrowdFlower::export(args.answer_type, Article.all_sampletags, filepath)
  end

  # run this like so:
  # rake crowd:export_all_sets[sports,crowdflower-round1,tmp] --trace 
  task :export, [:answer_type,:sampletag,:dir] => [:environment] do |t,args|
    Rails.logger.info "Starting to export --------------------------------"
    timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    filename = args.answer_type + "_" + args.sampletag + "_articles" + "_" + timestamp + ".csv"
    filepath = File.join(args.dir, filename )
    Rails.logger.info " to #{filepath}"
    CrowdFlower::export(args.answer_type, [args.sampletag], filepath)
  end
  
end
