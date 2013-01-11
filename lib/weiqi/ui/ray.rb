begin
  require "ray"
rescue LoadError
  abort("Weiqi requires the Ray gem when using standard Ruby:\n" +
        "https://github.com/Mon-Ouie/ray")
end

require_relative "../board"

module Weiqi
  class UI
    WINDOW_SIZE   = 800
    SCALE         = 30.0
    BOARD_OFFSET  = 125

    def self.run(game)
      game_runner = GameRunner.new
      scene       = game_runner.registered_scene(:main)
      scene.game  = game
      scene.board = Board.empty

      game.observe do |board|
        game.quit if game.finished?

        scene.board = board
        scene.update_board
      end

      game_runner.run
    end

    class MainScene < Ray::Scene
      scene_name :main

      attr_accessor :game, :board, :image

      def register
        self.frames_per_second = 30
        update_board

        on(:mouse_release) do |button, pos|
          x,y = ((pos.x - BOARD_OFFSET) / SCALE).round,
                ((pos.y - BOARD_OFFSET) / SCALE).round

          if (0...Board::SIZE).include?(x) && (0...Board::SIZE).include?(y)
            game.play(x,y)
          else
            game.pass
          end
        end
      end

      def render(win)
        win.draw @board_sprite
      end

      def update_board
        image = Ray::Image.new [WINDOW_SIZE, WINDOW_SIZE]        

        image_target image do |target|
          target.clear(Ray::Color.new(222, 185, 135, 255))

          (Board::SIZE - 1).times.to_a.product((Board::SIZE - 1).times.to_a) do |x,y|
            rect = Ray::Polygon.rectangle([0,0,SCALE,SCALE], Ray::Color.new(255, 250, 240, 255))
            rect.outlined = true
            rect.outline = Ray::Color.black

            # maybe move into constructor?
            rect.pos += [BOARD_OFFSET + x*SCALE, BOARD_OFFSET+y*SCALE]
            target.draw(rect)

            if Board::SIZE == 19
              [3,9,15].product([3,9,15]) do |dx, dy|
                circle = Ray::Polygon.circle([(BOARD_OFFSET + SCALE*dx),
                                              (BOARD_OFFSET + SCALE*dy)],
                                              5, Ray::Color.black)

                target.draw(circle)
              end
            end
          end

          board.white_stones.each do |x,y|
            stone = Ray::Polygon.circle([(BOARD_OFFSET + SCALE*x),
                                        (BOARD_OFFSET + SCALE*y)],
                                        14, Ray::Color.white)

            stone.outlined      = true
            stone.outline       = Ray::Color.black

            target.draw(stone)
           
            if board.last_move == [x,y]
              marker = Ray::Polygon.circle([(BOARD_OFFSET + SCALE*x),
                                            (BOARD_OFFSET + SCALE*y)], 
                                            8, Ray::Color.white)
              marker.outlined      = true
              marker.outline_width = 2
              marker.outline       = Ray::Color.black

              target.draw(marker)
            end
          end

          board.black_stones.each do |x,y|
            stone = Ray::Polygon.circle([(BOARD_OFFSET + SCALE*x),
                                        (BOARD_OFFSET + SCALE*y)],
                                        15, Ray::Color.black)

            target.draw(stone)

            if board.last_move == [x,y]
              marker = Ray::Polygon.circle([(BOARD_OFFSET + SCALE*x),
                                            (BOARD_OFFSET + SCALE*y)], 
                                            8, Ray::Color.black)
              
              marker.outlined      = true
              marker.outline_width = 2
              marker.outline       = Ray::Color.white

              target.draw(marker)
            end
          end

          target.update
        end

        @board_sprite = sprite(image)
      end
    end

    class GameRunner < Ray::Game
      def initialize
        super("Weiqi", :size => [WINDOW_SIZE, WINDOW_SIZE])

        MainScene.bind(self)
        
        scenes << :main
      end
      
      def register
        add_hook :quit, ->() { registered_scene(:main).game.quit }
      end
    end
  end
end
