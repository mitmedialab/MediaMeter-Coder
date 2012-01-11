Us vs. World News Coverage
==========================

I put the scraper public methods in `lib/news_scrapers.rb`, which refers to 
classes in `lib/news_scrapers`.

Installation
------------

Make sure you have Ruby 1.9.2 (we use rvm to get it).
Run `bundle` to get all the dependencies.
To create the db, run `rake db:migrate`.

Running
-------

You can code and test by running in the console:

```
> rails console
jruby-1.6.5 :001 > require 'news_scrapers'
jruby-1.6.5 :001 > NewsScrapers.scrape_all
```

or as a rake task (referring to `lib/tasks/scraper.db`):

```
> rake scraper:all --trace
```

Watch the log for lots of informative messages:
```
tail -f log/development.log 
```