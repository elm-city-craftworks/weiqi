begin
  require "ray"
rescue LoadError
  abort("Weiqi requires the Ray gem when using standard Ruby:\n" +
        "https://github.com/Mon-Ouie/ray")
end

require_relative "common"

module Weiqi
  module UI
    def self.run(game)
      game_runner = GameRunner.new
      scene       = game_runner.registered_scene(:main)
      scene.game  = game
      scene.view = BoardView.new

      ListenForChanges.(scene, game)

      game_runner.run
    end

    class GraphicsAdapter
      def initialize(canvas)
        self.canvas = canvas 
      end

      def draw_rect(params)
        rect = Ray::Polygon.rectangle(params.fetch(:box), Ray::Color.new(*params.fetch(:fill_color)))

        if params[:stroke_color]
          rect.outlined = true
          rect.outline  = Ray::Color.new(*params[:stroke_color])
        end

        canvas.draw(rect)
      end

      def draw_circle(params)
        center = params.fetch(:center)
        radius = params.fetch(:radius)
          
        radius -= params.fetch(:stroke_width,1)*2 if params[:stroke_color]

        circle = Ray::Polygon.circle(center, radius)

        if params[:fill_color]
          circle.color = Ray::Color.new(*params[:fill_color])
        end

        if params[:stroke_color]
          circle.outlined = true
          circle.outline  = Ray::Color.new(*params[:stroke_color])
          circle.outline_width = params[:stroke_width] if params[:stroke_width]
        end

        canvas.draw(circle)
      end

      private

      attr_accessor :canvas
    end

    class MainScene < Ray::Scene
      scene_name :main

      attr_accessor :game, :view, :image

      def register
        self.frames_per_second = 30
        repaint

        on(:mouse_release) { |_, pos| PlayMove.(game, pos.x, pos.y) }
      end

      def render(win)
        win.draw(board_sprite)
      end

      def repaint
        image = Ray::Image.new [WINDOW_SIZE, WINDOW_SIZE]        

        image_target image do |target|
          view.render(GraphicsAdapter.new(target))

          target.update
        end

        self.board_sprite = sprite(image)
      end

      private

      attr_accessor :board_sprite
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
