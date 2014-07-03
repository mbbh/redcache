module RedCache
  class Collector

    def initialize
      @rc = RedCache::Connector.new
      @callees = Hash.new
    end

    def register(path, lbda, blk)
        @callees[path] = [lbda, blk]
    end

    def get(path)
      data, ts = @rc.get_path_and_timestamp(path)
      lbda, blk = @callees[path]
      return data if @callees[path].nil? || lbda.call(ts)
      return @rc.set_path(path, blk.call)
    end

    def set(path, value)
      @rc.set_path(path, value)
    end
  end
end