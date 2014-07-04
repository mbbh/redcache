RedCache
========

#### What is RedCache?

Redcache is a very early stage caching library depending on redis and redis-rb. The idea is to allow for easy, hierachical data storage within redis, while providing utility functions to allow easy caching and retrieval of stored data adhering to the namespace paradigma.


#### Components

Currently RedCache consists of two main components: RedCache::Connector and
RedCache::Collector.

###### RedCache::Connector

- Contains lowlevel abstractions and the implementation of the namespace / hierachical mapping. Also contains lowlevel abstraction for timeout/persistance handling for keys stored in redis.

###### RedCache::Collector

- Contains highlevel caching functionality and ways to support automatic timeout
  on the application.

#### Examples

  examples/ssh_listing.rb : An example which demonstrates the use of the RedCache::Collector to actively query data from an ssh server (in this case
  executing a ls -l on a user specified directory) and storing this 'expensive'
  operation into the caching layer, only reexecuting it after a minute has passed.

#### Reequirements

  The caching layer was written to depend on very few gems. It requires
   - redis-rb
   - readline (part of stdlib, not a gem)
   - net-ssh (only for examples)
   - a working redis server listening on localhost
