require_relative "../board"

module Weiqi
  module UI
    WINDOW_SIZE   = 800
    SCALE         = 30.0
    BOARD_OFFSET  = 125

    ListenForChanges = ->(display, game) {
      game.observe do |board|
        game.quit if game.finished?

        display.view = BoardView.new(board)
        display.repaint
      end
    }

    PlayMove = ->(game, mouse_x, mouse_y) {
      x, y = ((mouse_x - BOARD_OFFSET) / SCALE).round, 
             ((mouse_y - BOARD_OFFSET) / SCALE).round

      if (0...Board::SIZE).include?(x) && (0...Board::SIZE).include?(y)
        game.play(x,y)
      else
        game.pass
      end
    }

    class BoardView
      def initialize(board = Board.empty)
        self.board = board
      end

      def render(canvas)
        paint_background(canvas)
        paint_grid(canvas)
        paint_star_points(canvas)
        paint_white_stones(canvas)
        paint_black_stones(canvas)
      end

      attr_accessor :board

      def paint_background(canvas)
        canvas.draw_rect(:fill_color  => [222, 184, 135],
                         :box         => [0, 0, WINDOW_SIZE, WINDOW_SIZE])

      end

      def paint_grid(canvas)
        (Board::SIZE - 1).times.to_a.product((Board::SIZE - 1).times.to_a) do |x,y|
          canvas.draw_rect(:fill_color    => [255, 250, 250],
                           :stroke_color  => [0,0,0],
                           :box           => [ BOARD_OFFSET + x*SCALE,
                                               BOARD_OFFSET + y*SCALE, SCALE, SCALE ])
        end
      end

      def paint_star_points(canvas)
        if Board::SIZE == 19
          [3,9,15].product([3,9,15]) do |dx, dy|
            canvas.draw_circle(:center     => [BOARD_OFFSET + SCALE*dx, BOARD_OFFSET + SCALE*dy],
                               :radius     => 5,
                               :fill_color => [0,0,0])
          end
        end
      end

      def paint_white_stones(canvas)
        board.white_stones.each do |x,y|
          canvas.draw_circle(:center      => [BOARD_OFFSET + SCALE*x,
                                              BOARD_OFFSET + SCALE*y],
                             :radius       => 15,
                             :fill_color   => [255, 255, 255],
                             :stroke_color => [0, 0, 0])

          if board.last_move == [x,y]
           canvas.draw_circle(:center       => [BOARD_OFFSET + SCALE*x,
                                                BOARD_OFFSET + SCALE*y],
                              :radius       => 10,
                              :stroke_color => [0,0,0],
                              :stroke_width => 2)
          end
        end
      end

      def paint_black_stones(canvas)
        board.black_stones.each do |x,y|
          canvas.draw_circle(:center     => [BOARD_OFFSET + SCALE*x,
                                             BOARD_OFFSET + SCALE*y],
                             :radius     => 15,
                             :fill_color => [0,0,0])

          if board.last_move == [x,y]
            canvas.draw_circle(:center       => [BOARD_OFFSET + SCALE*x,
                                                 BOARD_OFFSET + SCALE*y],
                               :radius       => 10,
                               :stroke_color => [255, 255, 255],
                               :fill_color   => [0, 0, 0],
                               :stroke_width => 2)
          end
        end
      end
    end
  end
end
