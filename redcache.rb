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

  def get_nodes_at(path)
    paths = cache_path(path)
    paths << "*"
    cursor = -1
    matches = []
    while(cursor.to_i != 0)
      cursor, m = @redis.scan((cursor == -1 ? 0 : cursor),
        :match => paths.join(internal_delim))
      matches += m
    end
    curold = @curpath
    matches.map {|k| unserialize_paths(k)}
  end

  def purge_nodes_at(path)
    @redis.del get_nodes_at(path).map {|k| cache_path_serialized(k)}
  end
end