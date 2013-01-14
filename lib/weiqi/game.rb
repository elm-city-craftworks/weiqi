module Weiqi
  class Game
    def initialize(engine)
      @engine    = engine
      @observers = []
      @history   = []
      @finished  = false
      @listening = true
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
      return unless @listening

      notify_observers(yield)
      @listening = false

      # FIXME: poor synchronization
      Thread.new do 
        notify_observers(@engine.play_white) 
        @listening = true
      end
    end

    def notify_observers(board)
      @history << board.last_move

      if @history.last(2) == ["PASS", "PASS"] 
        puts "Game over. Final score #{@engine.final_score}"
        quit
      elsif @history.last == "resign"
        puts "You win! The computer resigned"
        quit
      end

      @observers.each { |o| o.(board) }
    end
  end
end
