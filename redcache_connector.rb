require 'redis'

REDCACHE_INTERNAL_DELIM = "!DELIM-REDCACHE!"

module RedCache
  class Connector
    attr_reader :redis, :delim

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
      @delim + paths.split(internal_delim).join(@delim)
    end

    def set_path(path, file)
      @redis.set cache_path_serialized(path), Marshal.dump([file,Time.now])
      return file
    end

    def get_path_and_timestamp(path)
      data = @redis.get(cache_path_serialized(path))
      return data ? Marshal.load(data) : [nil, nil]
    end

    def get_path(path, default=nil)
      data,_ = get_path_and_timestamp(path)
      return data
    end

    def build_node_search_list(path)
      return ["*"] if path.nil? || path == @delim || path.empty?
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
      return ll_delete path if @redis.exists path
      nodes = get_nodes_at(path).map {|k| cache_path_serialized(k)}
      return nodes.all? {|n| ll_delete n }
    end

    def expire_path(path, time)
      @redis.expire(cache_path_serialized(path), time)
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

    def get_namespace
      @curpath.dup
    end

    def add_namespace(name)
      @curpath += @curpath[-1] == @delim ? name : @delim + name
    end

    def [](arg)
      return nil if arg.include?(@delim)
      get_path(arg)
    end

    def []=(arg, val)
      return nil if arg.include?(@delim)
      ll_delete arg if val.nil?
      set_path(arg, val)
    end

    def ll_delete(arg)
      @redis.del(arg) == 1 ? true : false
    end
  end
end