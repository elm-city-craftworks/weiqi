require_relative "common"

module Weiqi
  module UI
    include Java

    import java.awt.Color
    import java.awt.Graphics
    import java.awt.BasicStroke
    import java.awt.Dimension

    import java.awt.event.MouseAdapter
    import java.awt.event.WindowAdapter

    import java.awt.image.BufferedImage

    import javax.swing.JPanel
    import javax.swing.JFrame

    def self.run(game)
      panel = Panel.new
      panel.setPreferredSize(Dimension.new(WINDOW_SIZE, WINDOW_SIZE))
      panel.view = BoardView.new

      frame = JFrame.new
      frame.add(panel)
      frame.pack
      frame.show

      click_listener         = ClickListener.new
      quit_listener          = QuitListener.new
      
      click_listener.game    = game
      quit_listener.game     = game
      
      panel.addMouseListener(click_listener)
      frame.addWindowListener(quit_listener)

      ListenForChanges.(panel, game)
    end

    class ClickListener < MouseAdapter
      attr_accessor :game

      # http://stackoverflow.com/questions/3382330/mouselistener-for-jpanel-missing-mouseclicked-events
      def mouseReleased(event)
        PlayMove.(game, event.getX, event.getY)
      end
    end

    class QuitListener < WindowAdapter
      attr_accessor :game

      def windowClosing(event)
        game.quit
      end
    end

    class GraphicsAdapter
      def initialize(canvas)
        self.canvas = canvas
      end

      def draw_rect(params)
        if fill_color = params[:fill_color]
          canvas.setColor(Color.new(*fill_color))
          canvas.fillRect(*params.fetch(:box))
        end

        if stroke_color = params[:stroke_color]
          canvas.setColor(Color.new(*stroke_color))
          canvas.drawRect(*params.fetch(:box))
        end
      end

      def draw_circle(params)
        x, y   = params.fetch(:center)
        radius = params.fetch(:radius)

        if fill_color = params[:fill_color]
          canvas.setColor(Color.new(*fill_color))

          canvas.fillArc(x - radius, y - radius, radius*2, radius*2, 0, 360)
        end

        if stroke_color = params[:stroke_color]
          original_stroke = canvas.getStroke

          if stroke_width = params[:stroke_width]
            canvas.setStroke(BasicStroke.new(stroke_width))
          end

          canvas.setColor(Color.new(*stroke_color))
          
          canvas.drawArc(x - radius, y - radius, radius*2, radius*2, 0, 360)

          canvas.setStroke(original_stroke)
        end

      end

      private

      attr_accessor :canvas
    end

    class Panel < JPanel
      attr_accessor :view

      def paintComponent(g)
        image  = BufferedImage.new(WINDOW_SIZE, WINDOW_SIZE, BufferedImage::TYPE_INT_ARGB)
        canvas = image.getGraphics

        view.render(GraphicsAdapter.new(canvas))

        g.drawImage(image, 0, 0, nil)
        canvas.dispose
      end
    end
  end
end
