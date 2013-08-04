module PGN
  class FEN
    INITIAL = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    attr_accessor :string

    def initialize(str = INITIAL)
      self.string = str
    end

    def to_position
      board, active, castling, en_passant, halfmove, fullmove = self.string.split
      rows = board.split(/\//)
      rows = rows.map {|row| row.gsub(/\d/) {|match| "_" * match.to_i } }
      rows = rows.map {|row| row.split('') }
      rows = rows.map {|row| row.map {|r| r == '_' ? nil : r } }
      PGN::Position.new(rows, active, castling, en_passant, halfmove, fullmove)
    end

    def inspect
      self.string
    end
  end
end
