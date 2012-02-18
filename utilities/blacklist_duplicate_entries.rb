require '../config/environment.rb'

@duplicate_count = 0
@previous_duplicate_string = nil
Article.all(:conditions=>['blacklist_tag IS NULL or blacklist_tag="" or blacklist_tag ="duplicate"'], :order=>"pub_date asc, source, headline, abstract").each do |article|
  duplicate_string = article.headline.to_s + article.source.to_s + article.pub_date.to_s #+ article.abstract.to_s
  if duplicate_string == @previous_duplicate_string
    article.blacklist_tag = "duplicate"
    article.save
    print "x"
    @duplicate_count += 1
  end
  @previous_duplicate_string = duplicate_string
end

puts "Duplicate Count: #{@duplicate_count}"
