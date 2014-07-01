load 'redcache.rb'

def run(name, bool)
  if bool
    puts ("- %-25s [     OK ]" % name)
  else
    puts ("- %-25s [ FAILED ]" % name)
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

run "get_nodes_below", rc.get_nodes_at("foo/x/").sort == keys.sort
