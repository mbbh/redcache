load 'redcache.rb'
load 'redcache_test_helper.rb'

begin_test do
  @rcl = RedCache::Collector.new
  @rc  = RedCache::Connector.new

  run "test basic register functionality" do
    assert @rc.set_path("/test/b/c", "5")
    assert @rcl.register("/test/b/c", ->(ts) { false }, Proc.new do
      1+1
    end)
    assert_equal 2, @rcl.get("/test/b/c")
  end

  run "update lambda checks" do
    tn = Time.now
    assert @rc.set_path("/test/b/d", 5)
    assert @rcl.register("/test/b/d", ->(ts) { ts.to_i == tn.to_i }, Proc.new do
      raise "never should get here"
    end)
    assert_equal 5, @rcl.get("/test/b/d")
  end

  run "convinience set method" do
    assert @rcl.set("test/dce", "1")
    assert_equal @rcl.get("test/dce"), "1"
  end

  run "timeoutable automatical recalc" do
    @rcl.set("test/cached_entry", 5)
    assert @rcl.register("test/cached_entry", ->(ts) { true }, -> { 2 })
    @rcl.temporary("test/cached_entry", 1)
    assert_equal 5, @rcl.get("test/cached_entry")
    sleep 2
    assert_equal 2, @rcl.get("test/cached_entry")
  end
  purge_test_data(@rc.redis)
end