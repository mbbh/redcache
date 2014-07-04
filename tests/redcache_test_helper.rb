require 'redcache/redcache_color'

def test_ok
  print "\b\b\b\b\b\b\b\b\b\b[   "+ green("OK") + "   ]\n"
end

def test_failed
  print "\b\b\b\b\b\b\b\b\b\b[ "+ red("FAILED") + " ]\n"
end

def call_setup
  @fails = []
end

def call_teardown
  if @fails.any?
    puts "\nThe following tests have failed:"
    @fails.each do |name, fail|
      puts "T: #{name}\n  - #{fail}"
    end
  end
end

def record_failure
  @result = false
  @fails << [@name, caller.detect {|c| !(c =~ /#{__FILE__}/)}]
end

def run(name)
  @result = true
  @name = name
  print ("- %-70s  [ " % name) + "   *   ]"
  yield
  @result ? test_ok : test_failed
end

def begin_test
  call_setup
  yield
  call_teardown
end

def assert_equal(a, b)
  return unless @result
  record_failure if (a != b)
end

def assert(val)
  return unless @result
  record_failure unless val
end

def assert_equal_array(a, b)
  assert_equal(a.sort, b.sort)
end

def assert_nil(a)
  assert a.nil?
end

def assert_not(a)
  assert !a
end

def purge_test_data(redis)
  redis.keys("test*").each do |k|
    redis.del k
  end
end