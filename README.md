space-saver-redis
=================

This gem is a pure Ruby implementation of Metwally, Agrawal, and Abbadi's 
[SpaceSaver algorithm](http://www.cs.ucsb.edu/research/tech_reports/reports/2005-23.pdf) 
for estimating the top K elements in a data stream. A [Redis](http://redis.io) 
instance is used for storage.

Here's an example:

    require 'redis'
    require 'space-saver-redis'

    # Estimate the top 10 most frequent items seen in a data stream
    space_saver = SpaceSaver.new(Redis.new, 10)

    urls_visited.each { |url| space_saver.increment("urls", url) }

After the above code executes, you can query `space_saver.leaders("urls")` to get
an estimate of the top 10 most frequent URLs visited along with their estimated
counts. The `SpaceSaver` instance uses only a Redis sorted set with at most K 
elements (10, in this case) at any time to make this estimation. 

Obviously, since the data structure uses only a small, fixed amount of space,
there are some data distributions that can cause the top K elements returned to
be completely incorrect, but for a lot of data distributions the results are
worth the savings in space. In particular, for a `SpaceSaver` instance initialized
with parameter K that observes a data stream of N items, any item that occurs more
than N/K times is guaranteed to be in the list of estimated leaders.

One way to cope with the error involved in this kind of estimation is to use a K
bigger than you actually need and then truncate the number of leaders returned
at query time. You can pass an additional parameter to the call to `leaders` to
do this, for example `space_saver.leaders("urls", 3)` will return only the top
3 of the 10 estimated most frequent items.

Installation
============

    gem install space-saver-redis
