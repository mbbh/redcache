load 'redcache.rb'
load 'redcache_color.rb'
load 'redcache_test_helper.rb'

begin_test do
  @rc = RedCache::Connector.new

  run "simple get/set tests" do
    assert @rc.set_path("/test/getset/a", "1234")
    assert @rc.set_path("/test/getset/a", "5555")
    assert_equal @rc.get_path("/test/getset/a"), "5555"
  end

  run "get_nodes_at should handle 'directories'" do
    keys = (1..55).to_a.map {|i| "/test/getnodes/#{i}"}
    keys.each do |k|
      assert @rc.set_path(k, "1234")
    end

    assert_equal_array @rc.get_nodes_at("test/getnodes/"), keys.sort
  end

  run "running node purges" do
    assert @rc.set_path("test/purge", 1234)
    assert @rc.purge_nodes_at("test/purge")
    assert @rc.get_nodes_at("test/purge").empty?

    @rc["abc"] = true
    assert @rc.purge_nodes_at("abc")
    assert @rc["abc"].nil?
  end

  run "node purges on directories" do
    0.upto(15) {|i| @rc.set_path("test/purge_multi/node{i}", i) }
    @rc.purge_nodes_at("test/purge_multi/")
    0.upto(15) {|i| assert_not @rc.redis.exists "test/purge_multi/node#{i}"}
  end

  run "namespace handling" do
    assert (@rc.namespace "test" do
      assert @rc.set_path("ns_handling", "abc")
    end)

    assert @rc.set_path("ns_handling", 1234)
    assert_equal @rc.get_path("/test/ns_handling"), "abc"
    @rc.ll_delete("ns_handling")

    assert @rc.set_path("test/namespace/1", "hullo")
    assert @rc.set_namespace("test/namespace")
    assert_equal @rc["1"], "hullo"

    assert @rc.set_path("2", "abc")
    assert @rc.set_namespace("/")
    assert_equal @rc.get_path("test/namespace/2"), "abc"

    assert @rc.add_namespace("test")
    assert @rc.add_namespace("namespace2")
    assert_equal @rc.get_namespace, "/test/namespace2"
    @rc.set_namespace("/")
  end

  run "convinience operator [] and []=" do
    assert @rc["test"] = "abc"
    assert_equal @rc["test"], "abc"

    @rc["test"] = nil
    assert @rc.get_path("/test").nil?
  end

  run "path wildcard buliding" do
    assert_equal @rc.build_node_search_list("/"), ["*"]
    assert_equal @rc.build_node_search_list("/test/wc"), ["test","wc","*"]
  end

  run "path unserialisation" do
    assert @rc.add_namespace("test")
    assert_equal "/test/xyz",
      @rc.unserialize_paths(@rc.serialize_paths("xyz"))
  end

  run "low level delete function" do
    @rc.redis.set("test/delete/me", "1")
    assert @rc.ll_delete("test/delete/me")
    assert_nil @rc.redis.get("test/delete/me")
    assert_not @rc.ll_delete("test/delete/me")
  end

  run "expire_path support" do
    assert @rc.set_path("test/expire", "5")
    assert @rc.expire_path("test/expire", 1)
    sleep 1.1
    assert_nil @rc.get_path("test/expire")
  end

  run "persist_path support" do
    assert @rc.set_path("test/persist", "5")
    assert @rc.expire_path("test/persist", 1)
    sleep 0.1
    assert @rc.persist_path("test/persist")
    sleep 1.1
    assert_equal "5", @rc.get_path("test/persist")
  end

  purge_test_data(@rc.redis)
end