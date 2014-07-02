require 'redis'

REDCACHE_INTERNAL_DELIM = "!DELIM-REDCACHE!"

class RedCache
  attr_reader :redis

  def internal_delim
    @delim + REDCACHE_INTERNAL_DELIM + @delim
  end

  def cache_path(path)
    paths = path[0].to_s == @delim ?
      path.split(@delim) :
      @curpath.split(@delim) + path.split(@delim)
      return [@curpath] if paths.empty?
      return paths[0].empty? ? paths[1..-1] : paths
  end

  def initialize(delim="/")
    @redis = Redis.new(:host => "127.0.0.1")
    @curpath = delim
    @delim = delim
  end

  def cache_path_serialized(path)
    cache_path(path).join(internal_delim)
  end

  def unserialize_paths(paths)
    @curpath + paths.split(internal_delim).join(@delim)
  end

  def set_path(path, file)
    @redis.set cache_path_serialized(path), Marshal.dump(file)
  end

  def get_path(path, default=nil)
    data = @redis.get(cache_path_serialized(path))
    return data ? Marshal.load(data) : default
  end

  def build_node_search_list(path)
    return ["*"] if path.nil? || path == @curpath || path.empty?
    return ["#{path}/*"] unless path =~ %r{/?[^/]+/}
    return cache_path(path) << "*"
  end

  def get_nodes_at(path)
    paths = (build_node_search_list(path)).join(internal_delim)
    cursor, matches = @redis.scan(cursor, :match => paths)
    while(cursor.to_i != 0)
      cursor, m = @redis.scan(cursor, :match => paths)
      matches += m
    end
    return matches.map {|k| unserialize_paths(k)}
  end

  def purge_nodes_at(path)
    return @redis.del path if @redis.exists path
    nodes = get_nodes_at(path).map {|k| cache_path_serialized(k)}
    @redis.del nodes unless nodes.empty?
  end

  def namespace(name)
    oldcur = @curpath
    @curpath += (@curpath == @delim ? name : @delim + name)
    yield
    @curpath = oldcur
  end

  def set_namespace(name)
    @curpath = name[0] == @delim ? name : @delim + name
  end

  def [](arg)
    return nil if arg.include?(@delim)
    get_path(arg)
  end

  def []=(arg, val)
    return nil if arg.include?(@delim)
    @redis.del arg if val.nil?
    set_path(arg, val)
  end
end
