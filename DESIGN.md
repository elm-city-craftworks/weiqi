## Design Notes

Although it is a simple program, building Weiqi required me to work
through some interesting design decisions. I've done my best to summarize 
them below, in the hopes that they will help you understand why things 
have been implemented the way they are.

### Weiqi relies on the Go Text Protocol (GTP)

Internally, Weiqi uses a TCP socket to interact
with a listening game engine via [GTP commands][gtp]. While the current
implementation of Weiqi assumes that you are using [GNU Go][gnugo], 
multi-engine support might be straightfoward to implement. This
loosely coupled structure might also make it feasible to build a 
mock server for testing/debugging, along with other interesting 
engine hacks.

Weiqi's internal representation of the game board does not
implement any domain logic, instead, it relies on the engine
to handle all of those details. The state of the board is
stored in an SGF file (which is a standard game format for
computer Go), which is then parsed for stone coordinates
to display in the UI. This is another design decision that
hopefully makes the code a bit more flexible and extendible,
and definitely reduces the complexity of its implementation.
Weiqi uses the SGFParser gem for convenience, but so few
of its features are used that it could conceivably be replaced
with a few lines of regular expressions. That said, it's rarely
a good idea to roll your own makeshift parser when there is
already something readily available that gets the job done,
and SGFParser seems to be working fine.

For specific implementation details of the client code that
interacts with GNU Go, see **lib/weiqi/gnu_go.rb**. You may
also want to check out the trivial data object that implements the
game board in **lib/weiqi/board.rb**.

### Weiqi supports multiple graphics backends

Because the GUI for this application is very minimal (just simple
geometric shapes and basic event handling), it was straightforward
to implement support for multiple graphics backends. The code in 
**lib/weiqi/ui/common.rb** implements the GUI in abstract terms,
and then low-level adapters fill in the details for each graphics
backend.

On JRuby, Weiqi uses a AWT/Swing based backend, avoiding 
the need to install third-party graphics libraries. The code
for this is not exactly pretty, but it was easy enough to write.
See **lib/weiqi/ui/swing.rb** if you want to see exactly how it works.

On other Ruby implementations, Weiqi depends on the OpenGL based
Ray game library. Ray is slightly easier to work with in this context
than AWT/Swing because it implements a DSL specifically designed for
building 2D games with, but it has several dependencies that need
to be manually installed on all platforms except for Windows. See 
**lib/weiqi/ui/ray.rb** for more details.

### Weiqi uses an event-based mechanism for updating views

As we discussed earlier, Weiqi relies on the GNU Go engine to control the state 
of the game board. Each time a command is executed on the engine, the board
state is serialized using the SGF format, and then the Weiqi GUI parses
that file and updates its display.

Rather than having the UI poll for changes on regular intervals, a simple
callback based system is used instead. In the common UI code, you'll see
a function that looks like this:

```ruby
module Weiqi
  module UI
    ListenForChanges = ->(display, game) {
      game.observe do |board|
        game.quit if game.finished?

        display.view = BoardView.new(board)
        display.repaint
      end
    }
  end
end
```

This function is called by the application runner for
each graphics adapter to update the display whenever 
game state changes.

The basic idea is that each time a player clicks an empty 
intersection on the board, the callback gets triggered twice:
once for the board state after the player's move has been
accepted, and once again once the computer player has decided
its move. Because we can never guess precisely how long these
actions will take, a callback based system is much more efficent
than relying on polling here.

Another interesting consequence of this style of design is that the
UI is purely a delivery mechanism with almost no application-specific
knowledge. This made it possible to introduce the Ray-based
adapter with minimal effort even after the entire application had
been written for JRuby originally. It's hard to say whether this
basic architecture will start to show signs of brittleness when
additional features are added to this application, but it seems
to be working well so far.

If you're curious about the specific details of how this event-based
system is implemented, you can take a closer look at **lib/weiqi/game.rb** 
to see exactly how and when these observers get notified. Just be aware 
that although the basic design idea is sound, there are a few weak 
spots how this code is implemented! (They're discussed in its 
comments, and below).

## Known issues and caveats

Weiqi works well enough that you may be able to play a complete Go game without
experiencing any issues, but not well enough to guard against even relatively
simple error conditions. In other words, it works great as demo-ware, but to be
"production ready" it needs to be significantly more robust. Most (if not all)
of the issues with the code are due to things that were simply left undone due
to a lack of free time or a lack of experience, so I think they can definitely
be ironed out with a little effort.

While you can check the issue tracker for a comprehensive list of known bugs,
I've attempted to summarize them here so you know what to expect while working
with the codebase, and so that perhaps it might encourage you to share some
thoughts (or code) to help me fix these issues.

### Weiqi has a painful installation process

Look no farther than **README.md** to see that the installation process for this
gem badly leaves something to be desired for. It may be possible with some
effort to package up a standalone JRuby application that simply vendors all
of its dependencies, but I haven't really looked into it yet.

It should also be possible to package this library up as a gem, and perhaps
include a setup script that attempts to install dependencies. However, I
have done very little testing on other operating systems and ruby versions 
except for what is on my laptop, so I think this is some ways off.

I guess this is still the reason why we don't see a huge amount of desktop
Ruby applications, but suggestions are welcome!


### Weiqi has several missing UI features

Right now, there is no way to select your board size, preferred difficulty
level for the AI, handicap level, etc. All of these things would be important
for a comfortable Go playing program that was actually suitable for day-to-day
use, but I left them out. This was in part due to a desire to keep the
codebase small enough to be read in a single sitting, but also was a result of
me not having enough time to work on those features.

Perhaps more importantly, Weiqi does not actually display the final score within
the UI when the game is completed. Instead, the window abruptly closes, and the
score is printed out on the command line. Similarly, the only indication of PASS
moves is a line of text printed to the terminal, and so it is easy to miss those
and thing that the UI has simply become unresponsive. There are no technical
barriers to either of these issues, but it may mean that the protocol for
interacting with the UI will need to be expanded a bit to accomodate some
additional information.

### Weiqi takes a very naive approach to synchronization

When the player clicks on the board, `Game#move` gets called under
the hood. This method kicks off a Thread to process
the human and AI player's move in the background, notifying observers
twice during the process.

Synchronization is achieved using an awkward flag-based mechanism that
is almost certainly a sign of my lack of experience with proper threading
practices:

```ruby
module Weiqi
  class Game
    def move
      return unless @listening
      @listening = false

      Thread.new do 
        notify_observers(yield)

        notify_observers(@engine.play_white) 
        @listening = true
      end
    end
  end
end
```

Although this code seems to work, it may have subtle errors that I haven't been
able to detect yet, and so I have very little confidence in it. It also has a
fairly abrupt behavior: any move attempts that are made while other moves
are currently being processed are simply dropped. A better solution would
be to at least trigger an event that notifies the UI of failed requests in
some way. We could also queue up moves, but in practice that wouldn't make
much sense for a Go game.

### Broken socket connections during unexpected failures

Weiqi has to deal with threading, interprocess communication, fairly complex
graphics frameworks, and other things that go bump in the night. Because
I haven't managed to fully implement robust error handling, it is possible
for the application to crash abruptly. When that happens, the socket 
connection is occasionally not closed properly. Although I don't know
enough about socket programming to provide a clear explanation of this
problem, I know that when sockets aren't closed properly, they will
occasionally fail to respond until some operating-system level cleanup 
happens.

When this occurs, attempting to restart Weiqi after a crash may fail
until that cleanup happens. You'll see an error like this:

```Failed to listen on port 9002```

I suspect this is simply a bug or very bad behavior in Weiqi, and that
with proper error handling, I can make sure to do a safe cleanup. However,
a lack of visibility into the underlying sources of crashes has been
problematic, so I think we need to improve our debugging capabilities first.

### Lack of proper error handling and debugging capabilities

When something goes wrong, Weiqi is very tight lipped and doesn't give
you much useful information to work with. Some exceptions are probably
getting caught up in threads, or in the graphics system, and others
are due to a lack of error handling on the responses from GNU Go.



### Lack of automated tests / comprehensive documentation

## Final notes


[gtp]: http://www.lysator.liu.se/~gunnar/gtp/gtp2-spec-draft2/gtp2-spec.html
[gnugo]: http://www.gnu.org/software/gnugo/
[sgf]: http://www.red-bean.com/sgf/
