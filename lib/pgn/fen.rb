module PGN
  # This class is responsible for translating between strings in
  # Forsyth-Edwards notation and a representation of the board that is
  # appropriate for making moves.
  #
  class FEN
    # The FEN string representing the starting position in chess
    INITIAL = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    attr_accessor :fen
    attr_accessor :board, :active, :castling, :en_passant, :halfmove, :fullmove
    attr_accessor :squares

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

    # Sets @squares to a two dimensional array of the squares on the
    # board in the same order that is used in FEN. This representation
    # facilitates making moves. Occupied squares are represented using a
    # single letter, and unoccupied squares are represented by nil.
    #
    # @param board [String] the fen representation of the board
    #
    def board=(board)
      rows = board.split(/\//)
      rows = rows.map {|row| row.gsub(/\d/) {|match| "_" * match.to_i } }
      rows = rows.map {|row| row.split('') }
      rows = rows.map {|row| row.map {|r| r == '_' ? nil : r } }
      self.squares = rows.transpose.map(&:reverse)
    end

    # Turns the internal 2D array board representation into FEN format.
    #
    # @return ["String"] the fen representation of the board
    #
    def board
      rows = self.squares.map(&:reverse).transpose
      rows = rows.map {|row| row.map {|e| e.nil? ? "_" : e } }
      rows = rows.map {|row| row.join }
      rows = rows.map {|row| row.gsub(/_+/) {|match| match.length } }
      rows.join("/")
    end

    # @return [PGN::Position] the position corresponding to the fen
    # string
    #
    def to_position
      PGN::Position.new(self)
    end

    def to_s
      [
        self.board,
        self.active,
        self.castling,
        self.en_passant,
        self.halfmove,
        self.fullmove,
      ].join(" ")
    end

    def inspect
      self.fen
    end
  end
end
