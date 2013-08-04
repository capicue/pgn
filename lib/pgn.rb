require "pgn/board"
require "pgn/fen"
require "pgn/game"
require "pgn/position"
require "pgn/version"

module PGN
  def self.parse(pgn)
    pgn    = pgn.gsub(/\]\n\n/, "]\n")
    games  = pgn.split("\n\n")
    games.map do |game|
      game   = game.gsub("\n", " ")
      tags   = Hash[game.scan(/\[(.*?)\ \"(.*?)\"\]/)]
      moves  = game.gsub(/\[(.*?)\ \"(.*?)\"\]/, '').strip
      moves  = moves.split
      moves  = moves.delete_if {|m| m.match(/\d+\./) }
      result = moves.pop

      PGN::Game.new(tags, moves, result)
    end
  end
end
