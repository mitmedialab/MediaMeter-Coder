require 'crowd_flower'

namespace :crowd do
	
	desc "Import and export for CrowdFlower"
  
  # run this like so:
  # rake crowd:export_all_sets[sports,tmp] --trace 
  # bundle exec rake crowd:export_all_sets[foreign,tmp] --trace RAILS_ENV=production 
  task :export_all_sets, [:answer_type,:dir] => [:environment] do |t,args|
    Rails.logger.info "Starting to export --------------------------------"
    timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    filename = args.answer_type + "_" + "articles" + "_" + timestamp + ".csv"
    filepath = File.join(args.dir, filename )
    Rails.logger.info " to #{filepath}"
    CrowdFlower::export(args.answer_type, Article.all_sampletags, filepath)
  end

  # run this like so:
  # rake crowd:export[sports,crowdflower-round1,tmp] --trace 
  task :export, [:answer_type,:sampletag,:dir] => [:environment] do |t,args|
    Rails.logger.info "Starting to export --------------------------------"
    timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    filename = args.answer_type + "_" + args.sampletag + "_articles" + "_" + timestamp + ".csv"
    filepath = File.join(args.dir, filename )
    Rails.logger.info " to #{filepath}"
    CrowdFlower::export(args.answer_type, [args.sampletag], filepath)
  end
  
  
  # run this like so:
  # rake crowd:import[arts,crowdflower-20k,tmp/my_big_file.csv] --trace
  # bundle exec rake crowd:import[international,crowdflower-20k,tmp/20k-final/international-20k-final-a108387.csv] --trace RAILS_ENV=production 
  task :import, [:answer_type,:username,:filepath] => [:environment] do |t, args|
    user = User.find_by_username(args.username)
    Rails.logger.info "Starting to import #{user.username}'s #{args.answer_type} answers from #{args.filepath} --------------------------------"
    import_worked, feedback = Answer.import_from_csv(user, args.answer_type, args.filepath)    
  end
  
end
