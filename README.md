## Installation instructions

This project was developed on Mac OS X, but should work on 
all platforms. It has a few dependencies though, some of which you'll 
need to install manually.

### GNU Go

GNU Go is the game engine that actually understands how to play Go,
Weiqi is just a graphical client to it.  On most Linux distros, you should be
able to find this application in your package repository, so just install it as
you normally would other packages. On OS X, if you're using homebrew, you can
install it as follows:

```
  $ brew tap homebrew/games
  $ brew install gnu-go 
```

There is also a pre-built universal binary which seems to work, but you may need
to fiddle with your PATH in your shell in order to get it working. (In other
words, you're on your own!):

http://www.sente.ch/pub/software/goban/gnugo-3.7.11.dmg

I have not attempted to install GNU Go on Windows, but it looks like there are
binaries available there as well, but YMMV:

http://gnugo.baduk.org/

(Note: Please feel free to send a pull request to update this documentation
with what you needed to do to get things working on your platform)

