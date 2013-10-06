require "pgn/board"
require "pgn/fen"
require "pgn/game"
require "pgn/move"
require "pgn/move_calculator"
require "pgn/parser"
require "pgn/position"
require "pgn/version"

module PGN
  def self.parse(pgn)
    pgn.force_encoding(Encoding::ISO_8859_1)

    PGN::Parser.new.parse(pgn).map do |game|
      PGN::Game.new(game[:tags], game[:moves], game[:result])
    end
  end
end
