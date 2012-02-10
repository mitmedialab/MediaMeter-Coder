require '../config/environment.rb'

@duplicate_count = 0
@previous_headline_source_abstract = nil
Article.all(:conditions=>['blacklist_tag IS NULL'], :order=>"pub_date asc, source, headline, abstract").each do |article|
  headline_source_abstract = article.headline.to_s + article.source.to_s + article.abstract.to_s
  if headline_source_abstract == @previous_headline_source_abstract
    article.blacklist_tag = "duplicate"
    article.save
    print "x"
    @duplicate_count += 1
  end
  @previous_headline_source_abstract = headline_source_abstract
end

puts "Duplicate Count: #{@duplicate_count}"
