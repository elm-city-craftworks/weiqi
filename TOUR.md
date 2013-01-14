## Noteworthy implementation details

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

### Event-based view updates

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
each graphics adapter to allow its display to be updated
whenever the game state changes.

The basic idea is that each time a player clicks an empty 
intersection on the board, the callback gets triggered twice:
once for the board state after the player's move has been
accepted, and once again once the computer player has decided
its move. Because we can never guess precisely how long these
actions will take, a callback based system is much more efficent
than relying on polling here.

If you're curious about the specific details, you can take a closer 
look at the **lib/weiqi/game.rb** to see exactly how and when these 
observers get notified. Just be warned that there are a few weak
spots in that code! (They're discussed in its comments, and below).

## Known issues and caveats

* Synchronization issues
* Poor socket behavior during failures
* Error handling (in game and in app)
* Lack of good UI for scoring + passing
* No automated tests
* Installation process is painful

## Ideas for the future

* Gemify?
* TBD


[gtp]: http://www.lysator.liu.se/~gunnar/gtp/gtp2-spec-draft2/gtp2-spec.html
[gnugo]: http://www.gnu.org/software/gnugo/
[sgf]: 
