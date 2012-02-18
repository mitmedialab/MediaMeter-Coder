require '../config/environment.rb'

papers = ["Chicago Tribune", "LA Times", 
          "New York Times", "Washington Post"]

years = ["1979", "1989", "1999", "2009"]

total_articles_to_sample = 208

articles_per_paper_year = 208 / papers.size / years.size

papers.each do  | paper |
  years.each do | year |
    articles = Article.all(:conditions=>["source ='#{paper}' AND YEAR(pub_date) = '#{year}' AND blacklist_tag is null"], :order=>"pub_date asc, source, headline, abstract")
    next if !(articles.size > 0)

    sample_count = 0
    while sample_count < articles_per_paper_year
      article = articles[rand(0.. articles.size-1)]
      if(article.sampletag!="true")
        article.sampletag="true"
        article.save
        puts article.headline
        sample_count += 1
      end
    end
  end
end
