MediaMedia Coder
================

MediaMeter Coder is a tool for coding a set of text articles based on a set of 
questions.  The idea is that you can send the coding url to a set of trusted peers, and 
they can quickly code the set of articles based on questions you create.  Then you can
review their inter-coder agreement and create "gold" answers.

Installation
------------

Make sure you have Ruby 1.9.2 (we use rvm to get it).
Set up a database and enter the user/password into the `config/database.yml` file (we use mysql).
```
git clone url_to_repo
git checkout coding_engine
```

### Development Server

```
bundle install
rake db:migrate
```

### Production Server

If you're on Ubuntu machine make sure to do this so the mysql2 gem installs correctly:
```
sudo apt-get install libmysqlclient-dev
```

```
bundle install --deployment
bundle exec rake db:migrate RAILS_ENV=production`
```

Setup
-----

Copy `config/initializers/coding_engine.rb.template` to `config/initializers/coding_engine.rb`
and edit any settings in there you'd like to.

Visit the "Questions" page and add questions.  The question title, description, and
answers are shown on the coding page.  The title of each question will show up as an
option under the "Code" menu.

Backup
------

To backup your db to the tmp dir on a production server, run this:
```
bundle exec rake db:backup RAILS_ENV=production
```