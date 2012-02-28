require '../config/environment.rb'

@duplicate_count = 0
@previous_duplicate_string = nil
@previous_abstract = nil
Article.all(:conditions=>['(blacklist_tag IS NULL or blacklist_tag="" or blacklist_tag ="duplicate")'], :order=>"source, pub_date asc, headline asc, abstract").each do |article|
  duplicate_string = "" + article.headline.to_s[0..40] + article.source.to_s + article.pub_date.to_s + article.abstract.to_s[0..10]
  if duplicate_string == @previous_duplicate_string
    article.blacklist_tag = "duplicate"
    article.save
#    if @previous_abstract != article.abstract
#      puts 
#      puts @previous_abstract
#      puts article.abstract
#    end
    print "x"
    @duplicate_count += 1
  else if 
  end
  @previous_duplicate_string = duplicate_string
  @previous_abstract = article.abstract
end

puts "Duplicate Count: #{@duplicate_count}"
