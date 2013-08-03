module PGN
  class Position
    attr_accessor :board, :active, :castling, :en_passant, :halfmove, :fullmove

    def initialize(board, active, castling, en_passant, halfmove, fullmove)
      self.board      = board
      self.active     = active
      self.castling   = castling
      self.en_passant = en_passant
      self.halfmove   = halfmove
      self.fullmove   = fullmove
    end

    def to_fen
      fen_string = self.board.map do |row|
        row.join('').gsub(/_+/) {|match| match.length }
      end.join('/')
      fen_string = [fen_string, active, castling, en_passant, halfmove, fullmove].join(' ')
      PGN::FEN.new(fen_string)
    end

    def inspect
      result = [self.active, self.castling, self.en_passant, self.halfmove, self.fullmove].join(' ')
      result += "\n\n"
      result += self.board.map {|s| s.join(' ') }.join("\n")
    end
  end
end
