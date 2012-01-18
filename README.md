Us vs. World News Coverage
==========================

I put the scraper public methods in `lib/news_scrapers.rb`, which refers to 
classes in `lib/news_scrapers`.

Installation
------------

Make sure you have Ruby 1.9.2 (we use rvm to get it).
Run `bundle` to get all the dependencies.
To create the db, run `rake db:migrate`.

Scraping
--------

You can try out scraping by running in the console:

```
> rails console
jruby-1.6.5 :001 > require 'news_scrapers'
jruby-1.6.5 :001 > NewsScrapers.scrape_all
```

or as a rake task (referring to `lib/tasks/scraper.rake`):

```
> rake scraper:all --trace
> rake scraper:nytimes --trace
> rake scraper:latimes --trace
> rake scraper:chictrib --trace
> rake scraper:washpo --trace
```

Watch the log for lots of informative messages:
```
tail -f log/development.log 
```

Importing
---------

You can import aggregated answers from CrowdFlower by running a rake task like so

```
rake crowd:import[sports,../crowdflower-round-2/a77851.csv,is_this_article_about_sports,is_this_article_about_sports:confidence]
```

The arguments are:

* answer type - one of arts, foreign, international, local, national, or sports
* path to csv file
* column in the csv that has the aggregated answer
* column in the csv that has CrowdFlower's confidence in that answer


Exporting
---------

You can export aggregated answers to CrowdFlower by running a rake task like so

```
rake crowd:export[sports,tmp] --trace
```

The arguments are:

* answer type - one of arts, foreign, international, local, national, or sports
* folder to write the csv file that is generated
