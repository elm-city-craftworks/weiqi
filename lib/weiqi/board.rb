module Weiqi
  class Board
    def self.empty
      Board.new([], [], nil)
    end

    def initialize(black_stones, white_stones, last_move)
      @black_stones = black_stones
      @white_stones = white_stones
      @last_move    = last_move
    end

    def size
      19
    end

    attr_reader :black_stones, :white_stones, :last_move
  end
end
