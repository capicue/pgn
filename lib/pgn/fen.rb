module PGN
  # This class is responsible for translating between strings in
  # Forsyth-Edwards notation and a representation of the board that is
  # appropriate for making moves.
  #
  class FEN
    # The FEN string representing the starting position in chess
    INITIAL = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    attr_accessor :board, :active, :castling, :en_passant, :halfmove, :fullmove

    # http://en.wikipedia.org/wiki/Forsyth-Edwards_Notation
    #
    # @param fen [String] a string in Forsyth-Edwards Notation
    #
    def initialize(arg = INITIAL)
      case arg
      when String
        self.fen_string = arg
      when Hash
        arg.each do |key, val|
          self.send("#{key}=", val)
        end
      end
    end

    def en_passant=(val)
      @en_passant = val.nil? ? "-" : val
    end

    def castling=(val)
      @castling = (val.nil? || val.empty?) ? "-" : val
    end

    # @param board_fen [String] the fen representation of the board
    #
    def board_string=(board_fen)
      squares = board_fen.gsub(/\d/) {|match| "_" * match.to_i }
                         .split("/")
                         .map {|row| row.split('') }
                         .reverse
                         .transpose
      self.board = PGN::Board.new(squares)
    end

    def fen_string=(str)
      self.board_string,
        self.active,
        self.castling,
        self.en_passant,
        self.halfmove,
        self.fullmove = str.split
    end

    def fen_string
      self.squares
          .transpose
          .reverse
          .map {|row| row.join }
          .join("/")
          .gsub(/_+/) {|match| match.length }
    end

    # @return [PGN::Position] the position corresponding to the fen
    # string
    #
    def to_position
      PGN::Position.new(self)
    end

    def to_s
      [
        self.board.fen_string,
        self.active,
        self.castling,
        self.en_passant,
        self.halfmove,
        self.fullmove,
      ].join(" ")
    end

    def inspect
      self.to_s
    end
  end
end
