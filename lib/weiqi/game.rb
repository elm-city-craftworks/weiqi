require "thread"

module Weiqi
  class Game
    def initialize(engine)
      @engine    = engine
      @observers = []
      @history   = []
      @mutex     = Mutex.new
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
      return if @mutex.locked?

      Thread.new do 
        @mutex.synchronize do
          notify_observers(yield)

          notify_observers(@engine.play_white) 
        end
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
      elsif @history.last == "PASS"
        puts "PASS!"
      end

      @observers.each { |o| o.(board) }
    end
  end
end
