require "pgn/board"
require "pgn/fen"
require "pgn/game"
require "pgn/move"
require "pgn/move_calculator"
require "pgn/parser"
require "pgn/position"
require "pgn/version"

module PGN

  # @param pgn [String] a pgn representation of one or more chess games
  # @return [Array<PGN::Game>] a list of games
  #
  def self.parse(pgn)
    pgn.force_encoding(Encoding::ISO_8859_1)

    PGN::Parser.new.parse(pgn).map do |game|
      PGN::Game.new(game[:moves], game[:tags], game[:result])
    end
  end
end
