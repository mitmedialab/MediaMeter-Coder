require '../config/environment.rb'

if ARGV.count != 2
  puts "You need to supply two arguments - the number of articles to tag, and the tag to use"
  exit
end

total_articles_to_sample = ARGV[0].to_i
new_sampletag = ARGV[1]

puts "Starting script to sample #{total_articles_to_sample} articles with the sampletag '#{new_sampletag}'"

papers = Article.pluck(:source).uniq.sort
years = Article.pluck("YEAR(pub_date)").uniq.sort

puts "  Found #{papers.count} sources and #{years.count} years"

articles_per_paper_year = total_articles_to_sample / papers.size / years.size

puts "  Will sample #{articles_per_paper_year} articles for each year of each paper"

random = Random.new()

papers.each do  | paper |
  years.each do | year |
    puts "  Sampling #{paper}: #{year}"
    articles = Article.completed.where(:source=>paper, :blacklist_tag=>nil).where("YEAR(pub_date) = '#{year}'").
      order("pub_date asc, source, headline, abstract")
    next if !(articles.size > 0)

    sample_count = 0
    while sample_count < articles_per_paper_year
      article = articles[random.rand(0..articles.size-1)]
      if(article.sampletag!=new_sampletag)
        article.sampletag=new_sampletag
        article.save
        puts "    "+article.headline
        sample_count += 1
      end
    end
  end
end
