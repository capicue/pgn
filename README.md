# PGN

A PGN parser and FEN generator for ruby.

## Usage

### Creating games from pgn files

On the command line, it is easy to read in and play through chess games
in [portable game notation](http://en.wikipedia.org/wiki/Portable_Game_Notation) format.

```
> games = PGN.parse(File.read("./examples/immortal_game.pgn"))
> game  = games.first
> game.play
```

Play through the game using `a` to move backward and `d` to move
forward. `^C` quits play mode.

    ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
    ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
    ＿ ＿ ＿ ＿ ＿ ＿ ＿ ＿
    ＿ ＿ ＿ ＿ ＿ ＿ ＿ ＿
    ＿ ＿ ＿ ＿ ＿ ＿ ＿ ＿
    ＿ ＿ ＿ ＿ ＿ ＿ ＿ ＿
    ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
    ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖

    ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
    ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
    ＿ ＿ ＿ ＿ ＿ ＿ ＿ ＿
    ＿ ＿ ＿ ＿ ＿ ＿ ＿ ＿
    ＿ ＿ ＿ ＿ ＿ ＿ ＿ ＿
    ＿ ＿ ＿ ＿ ♙ ＿ ＿ ＿
    ＿ ＿ ＿ ＿ ＿ ＿ ＿ ＿
    ♙ ♙ ♙ ♙ ＿ ♙ ♙ ♙
    ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖

    ...

You can also access all of the information about a game.

```
> game.positions.last
=>
♜ ＿ ♝ ♚ ＿ ＿ ＿ ♜
♟ ＿ ＿ ♟ ♗ ♟ ♘ ♟
♞ ＿ ＿ ＿ ＿ ♞ ＿ ＿
＿ ♟ ＿ ♘ ♙ ＿ ＿ ♙
＿ ＿ ＿ ＿ ＿ ＿ ♙ ＿
＿ ＿ ＿ ♙ ＿ ＿ ＿ ＿
♙ ＿ ♙ ＿ ♔ ＿ ＿ ＿
♛ ＿ ＿ ＿ ＿ ＿ ♝ ＿

> game.positions.last.to_fen
=> r1bk3r/p2pBpNp/n4n2/1p1NP2P/6P1/3P4/P1P1K3/q5b1 b - - 1 22

> game.result
=> "1-0"

> game.tags["White"]
=> "Adolf Anderssen"
```

It is possible to create a game without parsing a pgn file.

```
moves = %w{e4 c5 c3 d5 exd5 Qxd5 d4 Nf6}
game = PGN::Game.new(moves)
```

Note that if you simply want an abstract syntax tree from the pgn file,
you can use `PGN::Parser.parse`.

### Dealing with FEN strings

[Forsyth Edwards Notation](http://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation)
is a compact way to represent all of the information about a given chess
position. It is easy to convert between FEN strings and chess positions.

```
> fen = PGN::FEN.start
=> rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1

> fen = PGN::FEN.new("r1bk3r/p2pBpNp/n4n2/1p1NP2P/6P1/3P4/P1P1K3/q5b1 b - - 1 22")
> position = fen.to_position
=>
♜ ＿ ♝ ♚ ＿ ＿ ＿ ♜
♟ ＿ ＿ ♟ ♗ ♟ ♘ ♟
♞ ＿ ＿ ＿ ＿ ♞ ＿ ＿
＿ ♟ ＿ ♘ ♙ ＿ ＿ ♙
＿ ＿ ＿ ＿ ＿ ＿ ♙ ＿
＿ ＿ ＿ ♙ ＿ ＿ ＿ ＿
♙ ＿ ♙ ＿ ♔ ＿ ＿ ＿
♛ ＿ ＿ ＿ ＿ ＿ ♝ ＿

> position.to_fen
=> r1bk3r/p2pBpNp/n4n2/1p1NP2P/6P1/3P4/P1P1K3/q5b1 b - - 1 22
```

## Installation

Add this line to your application's Gemfile:

    gem 'pgn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pgn

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
