require "thread"

module Weiqi
  class SequentialScheduler
    def run
      yield
    end
  end

  class AsyncScheduler
    def initialize
      @mutex = Mutex.new
    end

    def run(&block)
      return if @mutex.locked?

      @mutex.synchronize { yield }
    end
  end
end
