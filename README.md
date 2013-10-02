# PGN

A ruby parser for pgn files. 

## Usage

```ruby
games = PGN.parse(File.read("./examples/immortal_game.pgn"))
game  = games.first
game.play
```

Play through the game using `a` to move backward and `d` to move
forward. CTRL-C quits.

```
♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _
_ _ _ _ ♙ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ _ ♟ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ ♟ _ _ _
_ _ _ _ ♙ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
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
