require '../config/environment.rb'

count = 0
Article.all(:conditions=>['sampletag="true"']).each do |article|
  article.sampletag="hand-coded"
  article.save
  count +=1
end
puts "converted sampletags for #{count} articles"
