RedCache
========

#### What is RedCache?

Redcache is a very early stage caching library depending on redis and redis-rb. The idea is to allow for easy, hierachical data storage within redis, while providing utility functions to allow easy caching and retrieval of stored data adhering to the namespace paradigma.


#### Components

Currently RedCache consists of two main components: RedCache::Connector and
RedCache::Collector.

####### RedCache::Connector

- Contains lowlevel abstractions and the implementation of the namespace / hierachical mapping.

####### RedCache::Collector

- Contains highlevel caching functionality.
