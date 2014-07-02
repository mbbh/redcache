load 'redcache.rb'
load 'redcache_color.rb'
load 'redcache_test_helper.rb'

begin_test do
  @rc = RedCache.new

  run "simple get/set tests" do
    assert @rc.set_path("/foo/bar", "1234")
    assert @rc.set_path("foo/bar", "5555")
    assert_equal @rc.get_path("foo/bar"), "5555"
  end

  run "get_nodes_at should handle 'directories'" do
    keys = (1..55).to_a.map {|i| "/foo/x/baz#{i}"}
    keys.each do |k|
      assert @rc.set_path(k, "1234")
    end

    assert_equal_array @rc.get_nodes_at("foo/x/"), keys.sort
  end

  run "running node purges" do
    assert @rc.purge_nodes_at("foo/x/")
    assert @rc.get_nodes_at("foo/x/").empty?

    @rc["abc"] = true
    assert @rc.purge_nodes_at("abc")
    assert @rc["abc"].nil?
  end

  run "namespace handling" do
    assert (@rc.namespace "LALELU" do
      assert @rc.set_path("foo", "abc")
    end)

    assert @rc.set_path("foo", 1234)
    assert_equal @rc.get_path("/LALELU/foo"), "abc"

    assert @rc.set_path("abc/def/ghi", "hullo")
    assert @rc.set_namespace("abc/def")
    assert_equal @rc["ghi"], "hullo"

    assert @rc.set_path("xxx", "abc")
    assert @rc.set_namespace("/")
    assert_equal @rc.get_path("abc/def/xxx"), "abc"

    assert @rc.add_namespace("dir_a")
    assert @rc.add_namespace("dir_b")
    assert_equal @rc.get_namespace, "/dir_a/dir_b"
    @rc.set_namespace("/")
  end

  run "convinience operator [] and []=" do
    assert @rc["abc"] = "abc"
    assert_equal @rc["abc"], "abc"

    @rc["abc"] = nil
    assert @rc.get_path("/abc").nil?
  end

  run "path wildcard buliding" do
    assert_equal @rc.build_node_search_list("/"), ["*"]
    assert_equal @rc.build_node_search_list("/foo/bar"), ["foo","bar","*"]
  end

  run "path unserialisation" do
    assert @rc.add_namespace("abc")
    assert_equal "/abc/xyz",
      @rc.unserialize_paths(@rc.cache_path_serialized("xyz"))
  end

  @rc.redis.flushdb
end