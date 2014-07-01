load 'redcache.rb'

def run(name, bool)
  if bool
    puts ("- %-25s [     OK ]" % name)
  else
    puts ("- %-25s [ FAILED ]" % name)
  end
end

RedCache.setup
RedCache.set_path("/foo/bar", "1234")
RedCache.set_path("foo/bar", "5555")
run "simple get/set", RedCache.get_path("foo/bar") == "5555"

keys = (1..55).to_a.map {|i| "/foo/x/baz#{i}"}
keys.each do |k|
  RedCache.set_path(k, "1234")
end

run "get_nodes_below", RedCache.get_nodes_at("foo/x/").sort == keys.sort
