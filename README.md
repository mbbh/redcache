RedCache
========

#### What is RedCache?

RedCache is a very early stage caching library depending on redis and redis-rb. The idea is to allow for easy, hierachical data storage within redis, while providing utility functions to allow easy caching and retrieval of stored data adhering to the namespace paradigma.

#### Features

- High level caching and timeout APi to allow easy auto invalidation and
  recalculation on demand as well as verification based on timestamp of
  last recalculation.
- lowlevel API implementing Namespaces to redis with arbitary delimiters,
  defaulting to /. Internal delimiters written to redis are as unique as
  possible to prevent clashes with other implementations.
- support for lowlevel timeout/persistence API on the redis db.
- multi-instance support on the low level.

#### Components

Currently RedCache consists of two main components: RedCache::Connector and
RedCache::Collector.

###### RedCache::Connector

- Contains lowlevel abstractions and the implementation of the namespace / hierachical mapping. Also contains lowlevel abstraction for timeout/persistance handling for keys stored in redis.

###### RedCache::Collector

- Contains highlevel caching functionality and ways to support automatic timeout
  on the application.

#### Requirements

  The caching layer was written to depend on very few gems. It requires
   - redis-rb
   - readline (part of stdlib, not a gem)
   - net-ssh (only for examples)
   - a working redis server listening on localhost

#### Examples

   - examples/ssh_listing.rb : An example which demonstrates the use of the RedCache::Collector to actively query data from an ssh server (in this case executing a ls -l on a user specified directory) and storing this 'expensive' operation into the caching layer, only reexecuting it after a minute has passed.

#### Usage

##### RedCache::Collector

- basic interaction
```ruby
  require 'redcache'
  rcl = RedCache::Collector.new
  rcl.set("/test/entry/1", {:key_a => 3})
  hash = rcl.get("/test/entry/1")
```

- automatic calculation and recalculation
```ruby
  require 'redcache'
  rcl = RedCache::Collector.new
  rcl.register("/test/entry/5", true, -> {recalculate_data})
  rcl.temporary("/test/entry/5", 60)
  rcl.get("/test/entry/5") # calls recalculate_data and returns the result
  rcl.get("/test/entry/5") # fetches the stored result of reculate_data
  sleep 60.5
  rcl.get("/test/entry/5") # result expired, calling recalculate_data again
```

- using the verification function to determine whether a path needs recalculation
```ruby
  require 'redcache'
  rcl = RedCache::Collector.new
  rcl.register("/test/entry/42", ->(timestamp) {do_recalc?(timestamp)},
    -> {recalculate_data})
  rcl.get("/test/entry/42") # will call recalculate_data, nothing stored
  rcl.get("/test/entry/42") # will call do_recalc? with timestamp of last run.
```

##### RedCache::Connector

- basic get/set operations
```ruby
  require 'redcache'
  rc = RedCache::Connector.new("/") # param optionally is namespace delimiter
  rc.get_path("/test/entry/5/abc")  # get data from path
  rc.set_path("/test/entry/42", [1234,"abc"]) # store value at given path
```

- basic namespace operations
```ruby
  require 'redcache'
  rc = RedCache::Connector.new
  rc.set_namespace("/test/1")
  rc.get_path("tmp/5") # will access /test/1/tmp/5
  rc.add_namespace("tmp") # enter /test/1/tmp namespace
```

- persistance handling
```ruby
  require 'redcache'
  rc = RedCache::Connector.new
  rc.expire_path("/test/5", 60) # forces redis to delete /test/5 after 1 min
  rc.persist_path("/test/5") # undos the expire poperation
```