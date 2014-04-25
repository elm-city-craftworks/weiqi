module Weiqi
  class Game
    def initialize(engine, scheduler=Weiqi::AsyncScheduler.new)
      self.engine    = engine
      self.observers = []
      self.history   = []
      self.scheduler = scheduler
    end

    def observe(&block)
      observers << block
    end

    def pass
      move { engine.pass_black }
    end

    def play(x, y)      
      move { engine.play_black(x, y) }
    end

    def quit
      engine.quit
    end

    private

    attr_accessor :engine, :observers, :history, :scheduler
    
    def move
      scheduler.run do
        notify_observers(yield)

        notify_observers(engine.play_white) 
      end
    end

    def notify_observers(board)
      history << board.last_move

      if history.last(2) == ["PASS", "PASS"] 
        puts "Game over. Final score #{engine.final_score}"
        quit
      elsif history.last == "resign"
        puts "You win! The computer resigned"
        quit
      elsif history.last == "PASS"
        puts "PASS!"
      end

      observers.each { |o| o.(board) }
    end
  end
end
