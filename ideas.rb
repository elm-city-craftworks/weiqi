require "net/telnet"

# You can simplify this by using SGFParser gem...
# 
# sgf[/AB((\[\w\w\])+)/].scan(/\[(\w\w)\]/).flatten.map { |e| [("a".."z").to_a.index(e.chars.to_a.first), ("a".."z").to_a.index(e.chars.to_a.last)] }

Thread.new { system("gnugo --gtp-listen 9999 --mode gtp") }
sleep 2

gnugo = Net::Telnet.new("Host"    => "localhost",
                        "Port"    => "9999",
                        "Timeout" => false,
                        "Prompt"  => /^\n$/)

gnugo.cmd("showboard") { |c| print c }

gnugo.cmd("genmove B") 
gnugo.cmd("genmove W") 
gnugo.cmd("play B E6") 
gnugo.cmd("showboard") { |c| print c }

=begin
require "open3"


class GnuGo
  def initialize
    @input, @output, _, _ = Open3.popen3("gnugo --mode gtp")
  end

  def run(command)
    @input.puts(command)
    read_response(@output)
  end

  private

  def read_response(io)
    buffer = ""

    until (line = io.gets) == "\n"
      buffer << line
    end

    buffer
  end
end

require 'ray'

Ray.game("Hello world!", :size => [800, 600]) do
  players = ["B", "W"].cycle
  gnugo = GnuGo.new

  register { add_hook :quit, method(:exit!) }

   

  scene :hello do
    message = ""

    on :key_press, key(:a) do
      player  = players.next
      message = "#{player} #{gnugo.run("genmove #{player}")}"
    end

    on :key_press, key(:b) do
      message = gnugo.run("showboard")
    end
   
    render do |win| 
      label = text(message, :at => [100, 100], :size => 14, :font => "VeraMono.ttf")
      win.draw label
    end
  end

  scenes << :hello
end
=end
