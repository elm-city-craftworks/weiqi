## Points of interest


### Support for multiple graphics backends

- Because the GUI for this application is very minimal (just simple
  geometric shapes and basic event handling), it was straightforward
  to implement support for multiple graphics backends. The code in 
  _lib/weiqi/ui/common.rb_ implements the GUI in abstract terms,
  and then low-level adapters fill in the details for each graphics
  backend.

- On JRuby, Weiqi uses a AWT/Swing based backend, avoiding
  the need to install third-party graphics libraries. The code
  for this is not exactly pretty, but it was easy enough to write.
  See _lib/weiqi/ui/swing.rb_ if you want to see exactly how it works.

- On other Ruby implementations, Weiqi depends on the OpenGL based
  Ray game library. Ray is slightly easier to work with in this context
  than AWT/Swing because it implements a DSL specifically designed for
  building 2D games with, but it has several dependencies that need
  to be manually installed on all platforms except for Windows. See
  _lib/weiqi/ui/ray.rb_ for more details.

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
