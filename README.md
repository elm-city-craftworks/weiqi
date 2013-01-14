Weiqi is a network-based GTP client for GNU Go. It exists primarily as a
example codebase for the [Practicing Ruby](http://practicingruby.com)
journal. It is functional enough to play a complete game, but not stable
enough yet to be practical for day-to-day use. As you can see, the UI
is pretty minimal:

![Screenshot of Weiqi](http://i.imgur.com/kWrSg.png)

If you're here to complete the Practicing Ruby code reading exercise, or if
you're just curious about how this application is implemented, be sure to check
out the **DESIGN.md** file. It provides an overview of what is good, bad, and ugly
about Weiqi's codebase. But if you want to actually run Weiqi on your own
machine, installation and usage instructions follow below.

## Installation instructions

This project was developed on Mac OS X, but should work on 
all platforms. It has a few dependencies though, some of which you'll 
need to install manually.

I'm sorry the following instructions are somewhat lengthy but still a bit vague:
the project is in a very early stage and so I've not had a chance to streamline
the packaging yet. But in most cases, it should be fairly quick to get things up
and running, just a bit awkward.

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

### Ray (on platforms other than JRuby)

If you are using JRuby, you do not need to install any special graphics libraries 
to run Weiqi, as it ships with a Swing-based version that will work on JRuby out
of the box. But if you're using standard Ruby (or maybe even Rubinius
-- untested), you'll need to install Ray. It is listed in the project's Gemfile,
so running `bundle` will attempt to install it, but it has a few dependencies
of its own that you may not have installed on your system.

If you're on Windows, prebuilt dependencies are included in the gem, so you
don't need to do anything special.

If you're on OS X, you need `glew` and `libsndfile`. Here's how to install them
using Homebrew:

```
$ brew install glew libsndfile
```

On Linux, you need `glew` and `libsndfile`, but you also need freetype2, OpenAL,
and OpenGL. Check your package manager, and good luck!

(If you're running on a popular distro like Ubuntu or Debian, I'd appreciate it
if you contribute a pull request with specific install instructions!)

### Additional Dependencies

Assuming you have bundler handy, you can install all required gems as follows:

```
$ bundle
```

Peek at the Gemfile if you rather install your dependencies manually, but be
sure to stroke your beard (or your friend's beard) while you do so!

## Running Weiqi

Run the following command from the project root:

```
$ ruby bin/weiqi
```

This should display a Go board. You can click on any intersection to place your stones. 
Click anywhere in the area outside of the board to PASS, and close the window to resign. 
Upon completing a full game, the score will be posted to terminal.

If things don't work as expected, please check the installation instructions
again to make sure you didn't miss anything. If that doesn't work, go ahead
and file a ticket!

## License / Contribution Policy

This project is licensed under the 
[GNU General Public License, Version 3](http://www.gnu.org/licenses/gpl-3.0.txt).

Contributors retain full copyright to their contributions, but must agree to
license their work under the same license of the project itself.

## Questions?

Feel free to open a ticket or email **gregory@practicingruby.com**
