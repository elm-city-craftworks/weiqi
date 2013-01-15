module Weiqi
  class Board
    SIZE = 19

    def self.empty
      Board.new([], [], nil)
    end

    def initialize(black_stones, white_stones, last_move)
      self.black_stones = black_stones
      self.white_stones = white_stones
      self.last_move    = last_move
    end

    attr_reader :black_stones, :white_stones, :last_move

    private

    attr_writer :black_stones, :white_stones, :last_move
  end
end
