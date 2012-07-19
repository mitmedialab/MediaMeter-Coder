require 'global_brand'

namespace :brand do
	
	desc "Import and export for Global Brand study"
  
  # run this like so:
  # rake brand:import[path/to/dir] --trace 
  # bundle exec rake brand:import[path/to/dir] --trace  --trace RAILS_ENV=production 
  task :import, [:dir] => [:environment] do |t,args|
    GlobalBrand::import_from_evernote(args.dir)
  end
  
end
