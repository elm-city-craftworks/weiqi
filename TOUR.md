## Points of interest

### Weiqi uses the Go Text Protocol (gtp)

While the current implementation of Weiqi assumes that you are 
using [GNU Go][gnugo], multi-engine support might be straightfoward
to implement. Internally, Weiqi uses a TCP socket to interact
with a listening GNU Go process via [GTP commands][gtp]. This
loosely coupled structure might also make it feasible
to build a mock server for testing/debugging, along with 
other interesting engine hacks.

It's worth noting that it would have also been possible to
use pipes rather than sockets, but that lead to some 
complications on JRuby that weren't easily solveable. Using
sockets comes with its own set of issues, which we'll discuss
in more detail later on in this document.

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

* Observer-based interaction between models and UI
* Socket programming in GNU Go module
* Game as a controller object

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
