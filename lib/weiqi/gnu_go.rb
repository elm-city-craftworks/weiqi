require "tmpdir"
require "sgf"
require "socket"

require_relative "board"

module Weiqi
  class GnuGo
    HOST = "localhost"
    PORT = 9002

    def self.start_server
      Thread.new do
        system("gnugo --gtp-listen #{PORT} --mode gtp " +
                     "--boardsize #{Board::SIZE} --resign-allowed")
      end

      sleep 2
    end

    def pass_black
      command("play B PASS")

      update_board("PASS")
    end

    def play_black(x, y)
      coords = cartesian_to_gnugo(x, y)

      command("play B #{coords}")

      update_board(coords)
    end

    def play_white
      move = command("genmove W")

      update_board(move[2..-2])
    end

    def final_score
      command("final_score")
    end

    def quit
      command("quit")
      socket.close
    ensure
      exit!
    end

    private

    def update_board(last_move)
      Dir.mktmpdir do |dir|
        command("printsgf #{dir}/foo.sgf")

        parser = SGF::Parser.new
        game   = parser.parse("#{dir}/foo.sgf").games.first

        node   = game.current_node

        black_stones = (node[:AB] || []).map { |coord| sgf_to_cartesian(coord) }
        white_stones = (node[:AW] || []).map { |coord| sgf_to_cartesian(coord) }


        move = (["PASS","resign"].include?(last_move)) ? last_move : gnugo_to_cartesian(last_move)
      
        Board.new(black_stones, white_stones, move)
      end
    end

    def cartesian_to_gnugo(x,y)
      "#{(("A".."Z").to_a - ["I"])[x]}#{Board::SIZE - y}"
    end

    def sgf_to_cartesian(coord)
      alpha = ("a".."z").to_a
      [alpha.index(coord[0]), alpha.index(coord[1])]
    end

    def gnugo_to_cartesian(coord)
      alpha = ("A".."Z").to_a - ["I"]
      [alpha.index(coord[0]), Board::SIZE - Integer(coord[1..-1])]
    end

    def socket
      @socket ||= TCPSocket.new(HOST, PORT)
    end

    def command(msg)
      socket.puts(msg)

      socket.take_while { |line| line != "\n" }.join
    end
  end
end

