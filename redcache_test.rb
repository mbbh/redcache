load 'redcache.rb'

def run(name, bool)
  if bool
    puts ("- %-70s [     OK ]" % name)
  else
    puts ("- %-70s [ FAILED ]" % name)
  end
end

rc = RedCache.new
rc.set_path("/foo/bar", "1234")
rc.set_path("foo/bar", "5555")
run "simple get/set", rc.get_path("foo/bar") == "5555"

keys = (1..55).to_a.map {|i| "/foo/x/baz#{i}"}
keys.each do |k|
  rc.set_path(k, "1234")
end

run "get_nodes_at", rc.get_nodes_at("foo/x/").sort == keys.sort

rc.purge_nodes_at("foo/x/")
run "purge_nodes_at", rc.get_nodes_at("foo/x/").empty?


rc.namespace "LALELU" do
  rc.set_path("foo", "abc")
end
rc.set_path("foo", 1234)

run "namespace get/set", rc.get_path("/LALELU/foo") == "abc"

rc["abc"] = "abc"
run "convinience operator test", rc["abc"] == "abc"

rc["abc"] = nil
run "convinence operator should delete", rc.get_path("/abc").nil?

rc.redis.flushdb
