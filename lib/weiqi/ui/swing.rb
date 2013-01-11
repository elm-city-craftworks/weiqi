require_relative "../board"

module Weiqi
  class UI
    WINDOW_SIZE   = 800
    SCALE         = 30.0
    BOARD_OFFSET  = 125

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
      panel.setPreferredSize(Dimension.new(800, 800))

      frame = JFrame.new
      frame.add(panel)
      frame.pack
      frame.show

      move_listener      = MoveListener.new
      move_listener.game = game

      quit_listener      = QuitListener.new
      quit_listener.game = game

      game.observe do |board| 
        game.quit if game.finished?
         
        panel.board = board 
        panel.repaint
      end
      
      panel.addMouseListener(move_listener)
      frame.addWindowListener(quit_listener)
    end

    class MoveListener < MouseAdapter
      attr_accessor :game

      # http://stackoverflow.com/questions/3382330/mouselistener-for-jpanel-missing-mouseclicked-events
      def mouseReleased(event)
        x, y = ((event.getX - BOARD_OFFSET) / SCALE).round, 
               ((event.getY - BOARD_OFFSET) / SCALE).round

        if (0...Board::SIZE).include?(x) && (0...Board::SIZE).include?(y)
          game.play(x,y)
        else
          game.pass
        end
      end
    end

    class QuitListener < WindowAdapter
      attr_accessor :game

      def windowClosing(event)
        game.quit
      end
    end

    class Panel < JPanel
      def board
        @board ||= Board.empty
      end

      attr_writer :board

      def paintComponent(g)
        image = BufferedImage.new(WINDOW_SIZE, WINDOW_SIZE, BufferedImage::TYPE_INT_ARGB)

        bg = image.getGraphics
        
        bg.setColor(Color.new(222, 184, 135, 255))
        bg.fillRect(0,0,image.getWidth, image.getHeight)

        bg.setStroke(BasicStroke.new(1))

        (Board::SIZE - 1).times.to_a.product((Board::SIZE - 1).times.to_a) do |x,y|
          bg.setColor(Color.new(255, 250, 240, 255))
          bg.fillRect(125+x*30,125+y*30,30,30)
          bg.setColor(Color.black)
          bg.drawRect(BOARD_OFFSET + x*SCALE,
                      BOARD_OFFSET + y*SCALE,
                      SCALE, SCALE)
        end

        
        bg.setColor(Color.black)

        # this draws star points
        if Board::SIZE == 19
          [3,9,15].product([3,9,15]) do |dx, dy|
            bg.fillArc((BOARD_OFFSET - 5) + SCALE*dx, 
                       (BOARD_OFFSET - 5) + SCALE*dy, 
                       10, 10, 0, 360)
          end
        end


        board.white_stones.each do |x,y|
          bg.setColor(Color.white)
          bg.fillArc((BOARD_OFFSET - 15) + SCALE*x, 
                     (BOARD_OFFSET - 15) + SCALE*y, 
                     30, 30, 0, 360)

          bg.setColor(Color.black)
          bg.drawArc((BOARD_OFFSET - 15) + SCALE*x, 
                     (BOARD_OFFSET - 15) + SCALE*y, 
                     30, 30, 0, 360)

          if board.last_move == [x,y]
            bg.setStroke(BasicStroke.new(2))
            bg.drawArc((BOARD_OFFSET - 10) + SCALE*x,
                       (BOARD_OFFSET - 10) + SCALE*y,
                       20, 20, 0, 360)
            bg.setStroke(BasicStroke.new(1))
          end
        end

        board.black_stones.each do |x,y|
          bg.setColor(Color.black)

          bg.fillArc((BOARD_OFFSET - 15) + SCALE*x, 
                     (BOARD_OFFSET - 15) + SCALE*y, 
                     30, 30, 0, 360)

          if board.last_move == [x,y]
            bg.setColor(Color.white)
            bg.setStroke(BasicStroke.new(2))
            bg.drawArc((BOARD_OFFSET - 10) + SCALE*x,
                       (BOARD_OFFSET - 10) + SCALE*y,
                       20, 20, 0, 360)
            bg.setStroke(BasicStroke.new(1))
          end

        end

        g.drawImage(image, 0, 0, nil)
        bg.dispose
      end
    end
  end
end
