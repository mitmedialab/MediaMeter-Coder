Us vs. World News Coverage
==========================

I put the scraper public methods in `lib/news_scrapers.rb`, which refers to classes in `lib/news_scrapers`.  The code that parses a single webpage is in `app/models/article.rb`, since it might generalize.

Installation
------------
For now it is using a sqlite db, located at db/development.sqlite3.  To create the db, run `rake db:migrate`.

Running
-------

I code and test by running in the console (for good stack traces on errors):

```
> rails console
jruby-1.6.5 :001 > require 'news_scrapers'
jruby-1.6.5 :001 > NewsScrapers.scrape_all
```

or as a rake task (referring to `lib/tasks/scraper.db`):

```
> rake scraper:all
```

Watch the log for informative messages:
```
tail -f log/development.log 
```