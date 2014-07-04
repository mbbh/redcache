Gem::Specification.new do |s|
  s.name        = 'redcache'
  s.version     = '0.0.1'
  s.date        = '2014-07-04'
  s.executables = ["redcache_cli.rb"]
  s.summary     = "A basic caching solution based on redis"
  s.description = <<-EOF
A basic caching solution using redis as a backend, featuring on demand recalculation,
timeout and namespace-nested fast caching using redis.
  EOF
  s.authors     = ["Martin Hauser"]
  s.email       = 'mh@wrongexit.de'
  s.files       = ["lib/redcache.rb", "lib/redcache/collector.rb",
    "lib/redcache/connector.rb", "lib/redcache/color.rb"]
  s.homepage    = "http://github.com/mbbh/redcache"
  s.license     = 'BSD'
end
