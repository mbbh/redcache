module RedCache
  class Collector

    def initialize
      @rc = RedCache::Connector.new
      @callees = Hash.new
      @timeouts = Hash.new
    end

    def register(path, lbda, blk)
        @callees[path] = [lbda, blk]
    end

    def get(path)
      data, ts = @rc.get_path_and_timestamp(path)
      lbda, blk = @callees[path]

      if @callees[path].nil?
        return data
      end

      if data && (lbda == true || (lbda.respond_to?(:call) && lbda.call(ts)))
        return data
      end

      if timeout = @timeouts[path]
        @rc.expire_path(path, timeout)
      end
      return @rc.set_path(path, blk.call)
    end

    def set(path, value)
      result = @rc.set_path(path, value)
      if timeout = @timeouts[path]
        @rc.expire_path(path, timeout)
      end
      return result
    end

    def temporary(path, timeout)
      @timeouts[path] = timeout
      @rc.expire_path(path, timeout)
    end

    def persist(path)
      @timeouts.delete(path)
      @rc.persist_path(path)
    end
  end
end