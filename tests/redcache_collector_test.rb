load 'redcache.rb'
load 'redcache_test_helper.rb'

begin_test do
  @rcl = RedCache::Collector.new
  @rc  = RedCache::Connector.new

  run "test basic register functionality" do
    assert @rc.set_path("/a/b/c", "5")
    assert @rcl.register("/a/b/c", ->(ts) { false }, Proc.new do
      1+1
    end)
    assert_equal 2, @rcl.get("/a/b/c")
  end

  run "update lambda checks" do
    tn = Time.now
    assert @rc.set_path("/a/b/d", 5)
    assert @rcl.register("/a/b/d", ->(ts) { ts.to_i == tn.to_i }, Proc.new do
      raise "never should get here"
    end)
    assert_equal 5, @rcl.get("/a/b/d")
  end

  run "convinience set method" do
    assert @rcl.set("adc/dce", "1")
    assert_equal @rcl.get("adc/dce"), "1"
  end
  @rc.redis.flushdb
end