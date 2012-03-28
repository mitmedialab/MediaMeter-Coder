Us vs. World News Coverage
==========================

I put the scraper public methods in `lib/news_scrapers.rb`, which refers to 
classes in `lib/news_scrapers`.

Installation
------------

Make sure you have Ruby 1.9.2 (we use rvm to get it).
Run `bundle` to get all the dependencies.
To create the db, run `rake db:migrate`.

On a production Ubuntu machine do:
```
sudo apt-get install libmysqlclient-dev
bundle install --deployment
```

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
