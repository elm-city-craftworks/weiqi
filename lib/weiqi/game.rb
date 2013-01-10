module Weiqi
  class Game
    def initialize(engine)
      @engine    = engine
      @observers = []
      @history   = []
      @finished  = false
    end

    def finished?
      @finished
    end

    def observe(&block)
      @observers << block
    end

    def pass
      move { @engine.pass_black }
    end

    def play(x, y)      
      move { @engine.play_black(x, y) }
    end

    def quit
      @engine.quit
    end

    private

    def move
      notify_observers(yield)
    
      Thread.new { notify_observers(@engine.play_white) }
    end

    def notify_observers(board)
      @history << board.last_move

      @finished = true if @history.last(2) == ["PASS", "PASS"]

      @observers.each { |o| o.(board) }
    end
  end
end
