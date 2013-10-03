module PGN
  class FEN
    # The FEN string representing the starting position in chess
    INITIAL = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    attr_accessor :fen, :board, :active, :castling, :en_passant, :halfmove, :fullmove

    # http://en.wikipedia.org/wiki/Forsyth-Edwards_Notation
    #
    # @param fen [String] a string in Forsyth-Edwards Notation
    #
    def initialize(fen = INITIAL)
      self.fen = fen
      self.board,
        self.active,
        self.castling,
        self.en_passant,
        self.halfmove,
        self.fullmove = self.fen.split
    end

    # Returns a two dimensional array of the squares on the board in the
    # same order that is used in FEN. Used in initializing a new
    # {PGN::Position}. Occupied squares are represented using a single
    # letter, and unoccupied squares are represented with nil.
    #
    # @return [Array<Array<String, nil>>] the squares on the board
    #
    def squares
      @squares ||= begin
        rows = board.split(/\//)
        rows = rows.map {|row| row.gsub(/\d/) {|match| "_" * match.to_i } }
        rows = rows.map {|row| row.split('') }
        rows = rows.map {|row| row.map {|r| r == '_' ? nil : r } }
      end
    end

    # @return [PGN::Position] the position corresponding to the fen
    # string
    #
    def to_position
      PGN::Position.new(
        self.squares,
        self.active,
        self.castling,
        self.en_passant,
        self.halfmove,
        self.fullmove
      )
    end

    def inspect
      self.fen
    end
  end
end
