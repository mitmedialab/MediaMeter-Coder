Things to Do
============

Data Needed to Replicate MST
----------------------------

*Page number(s)*

So far it looks like we are getting some kind of page numbers for every article.  That said, sometimes they are simple things like "1" but others they are things like  "E4".  This also appears to be inconsistent within a single source between years.  This is to help us answer questions like "within the first ten pages?", and "on front page?".  I think we'll need to build some custom logic in code to answer these.  Alternatively, it looks like the ProQuest supports a search just for front page stories, at least for some sets of some papers - so it may help to write a secondary scraper that just pulls those results and flags already scraped articles. 

*Number of stories in the newspaper, per day*

Once we decide on our definition of "article", this won't be a problem.

*Total pages per day*

This depends on the quality of the "page" data we get from our scraping sources.  If it is good and complete, this will be a simple query against our article database table.

*Location of correspondent*

This depends on the quality of the "byline" data we get from our scraping sources.  My initial review makes it seems highly unlikely that we'll get anything good for this one.
 
*Number of international stories in the newspaper, per day*

We'll get this from the crowdsourcing.

*International, and related to politics?*

We'd have to crowdsource this one, but I think we can leave it out since it only relates to a small section fo their report.

*International, and related to the country of publication*

We'll get this from the crowdsourcing.

*International, and unrelated to country of publication*

We'll get this from the crowdsourcing.
