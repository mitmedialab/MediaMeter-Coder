MediaMedia Coder
================

MediaMeter Coder is a tool for coding a set of text articles based on a set of 
questions.  The idea is that you can send the coding url to a set of trusted peers, and 
they can quickly code the set of articles based on questions you create.  Then you can
review their inter-coder agreement and create "gold" answers.

Installation
------------

Make sure you have Ruby 1.9.2 (we use rvm to get it).
Run `bundle install` to get all the dependencies.
To create the db, run `rake db:migrate`.

On a production Ubuntu machine do:
```
sudo apt-get install libmysqlclient-dev
bundle install --deployment
```

Set up a mysql database and enter the user/password into the `config/database.yml` file.

Setup
-----

Visit the "Questions" page and add questions.  The question title, description, and
answers are shown on the coding page.  The title of each question will show up as an
option under the "Code" menu.