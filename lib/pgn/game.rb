module PGN
  class Game
    attr_accessor :tags, :moves, :result

    def initialize(tags, moves, result)
      self.tags   = tags
      self.moves  = moves
      self.result = result
    end

    def fen_list
      list = []
      position = PGN::Position.start
      list << position.to_fen.inspect
      self.moves.each do |move|
        position.move(move)
        list << position.to_fen.inspect
      end
      list
    end
  end
end
