require "open3"

def response(io)
  buffer = ""

  until (line = io.gets) == "\n"
    buffer << line
  end

  buffer
end

Open3.popen3("gnugo --mode gtp") do |stdin, stdout, stderr, wait_thr|
 stdin.puts("play B D16")
 puts response(stdout)

 stdin.puts("play W E16")
 puts response(stdout)

 stdin.puts("genmove B")
 puts response(stdout)
  puts "got here"

 stdin.puts("play W E16")
 puts response(stdout)
end
