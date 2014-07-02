load 'redcache.rb'

def colorize(text, color_code)
  "#{color_code}#{text}\e[0m"
end

def red(text); colorize(text, "\e[31m"); end
def green(text); colorize(text, "\e[32m"); end
def blue(text); colorize(text, "\e[34m"); end


def run(name, bool)
  if bool
    puts (("- %-70s [     "+green("OK")+" ]") % name)
  else
    puts (("- %-70s [ "+ red("FAILED")+" ]") % name)
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

run "empty path should lead to /*", rc.build_node_search_list("/") == ["*"]
run "search path for foo should lead to /foo/*",
  rc.build_node_search_list("/foo") == ["foo", "*"]

rc.set_path("abc/def/ghi", "hullo")
rc.set_namespace("abc/def")
run "namespace setting should function correctly", rc["ghi"] == "hullo"

rc.set_path("xxx", "abc")
rc.set_namespace("/")
run "namespace removing should scale correctly",
  rc.get_path("abc/def/xxx") == "abc"



rc.redis.flushdb
