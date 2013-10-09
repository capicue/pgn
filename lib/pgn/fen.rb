module PGN
  # {PGN::FEN} is responsible for translating between strings in FEN
  # notation and an internal representation of the board.
  #
  # @see http://en.wikipedia.org/wiki/Forsyth-Edwards_Notation
  #   Forsyth-Edwards notation
  #
  # @!attribute board
  #   @return [PGN::Board] a {PGN::Board} object for the current board
  #     state
  #
  # @!attribute active
  #   @return ['w', 't'] the current player
  #
  # @!attribute castling
  #   @return [String] the castling availability
  #   @example
  #     "Kq" # white can castle kingside and black queenside
  #   @example
  #     "-"  # no one can castle
  #
  # @!attribute en_passant
  #   @return [String] the current en passant square
  #   @example
  #     "e3" # white just moved e2 -> e4
  #     "-"  # no current en passant square
  #
  # @!attribute halfmove
  #   @return [String] the halfmove clock
  #   @note This is the number of halfmoves since the last pawn advance or capture
  #
  # @!attribute fullmove
  #   @return [String] the fullmove counter
  #   @note The number of full moves. This is incremented after black
  #     plays.
  #
  class FEN
    # The FEN string representing the starting position in chess
    #
    INITIAL = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    attr_accessor :board, :active, :castling, :en_passant, :halfmove, :fullmove

    # @return [PGN::FEN] a {PGN::FEN} object representing the starting
    #   position
    #
    def self.start
      PGN::FEN.new(INITIAL)
    end

    # @return [PGN::FEN] a {PGN::FEN} object with the given attributes
    #
    def self.from_attributes(attrs)
      fen = PGN::FEN.new
      attrs.each do |key, val|
        fen.send("#{key}=", val)
      end
      fen
    end

    # @param fen_string [String] a string in Forsyth-Edwards Notation
    #
    def initialize(fen_string = nil)
      if fen_string
        self.board_string,
          self.active,
          self.castling,
          self.en_passant,
          self.halfmove,
          self.fullmove = fen_string.split
      end
    end

    def en_passant=(val)
      @en_passant = val.nil? ? "-" : val
    end

    def castling=(val)
      @castling = (val.nil? || val.empty?) ? "-" : val
    end

    # @param board_fen [String] the fen representation of the board
    # @example
    #   fen.board_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
    #
    def board_string=(board_fen)
      squares = board_fen.gsub(/\d/) {|match| "_" * match.to_i }
                         .split("/")
                         .map {|row| row.split('') }
                         .map {|row| row.map {|e| e == "_" ? nil : e } }
                         .reverse
                         .transpose
      self.board = PGN::Board.new(squares)
    end

    # @return [String] the fen representation of the board
    # @example
    #   PGN::FEN.start.board_string #=> "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
    #
    def board_string
      self.board
          .squares
          .transpose
          .reverse
          .map {|row| row.map {|e| e.nil? ? "_" : e } }
          .map {|row| row.join }
          .join("/")
          .gsub(/_+/) {|match| match.length }
    end

    # @return [PGN::Position] a {PGN::Position} representing the current
    #   position
    #
    def to_position
      player     = self.active == 'w' ? :white : :black
      castling   = self.castling.split('') - ['-']
      en_passant = self.en_passant == '-' ? nil : en_passant

      PGN::Position.new(
        self.board,
        player,
        castling,
        en_passant,
        self.halfmove.to_i,
        self.fullmove.to_i,
      )
    end

    # @return [String] the FEN string
    # @example
    #   PGN::FEN.start.to_s #=> "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    #
    def to_s
      [
        self.fen_string,
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
