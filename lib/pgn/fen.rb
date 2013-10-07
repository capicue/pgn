module PGN
  # This class is responsible for translating between strings in
  # Forsyth-Edwards notation and a representation of the board that is
  # appropriate for making moves.
  #
  class FEN
    # The FEN string representing the starting position in chess
    INITIAL = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    attr_accessor :board, :active, :castling, :en_passant, :halfmove, :fullmove

    def self.start
      PGN::FEN.new(INITIAL)
    end

    def self.from_attributes(attrs)
      fen = PGN::FEN.new
      attrs.each do |key, val|
        fen.send("#{key}=", val)
      end
      fen
    end

    # http://en.wikipedia.org/wiki/Forsyth-Edwards_Notation
    #
    # @param fen [String] a string in Forsyth-Edwards Notation
    #
    def initialize(fen_string = nil)
      self.fen_string = fen_string if fen_string
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
      self.board
          .squares
          .transpose
          .reverse
          .map {|row| row.join }
          .join("/")
          .gsub(/_+/) {|match| match.length }
    end

    def to_position
      player     = self.active == 'w' ? :white : :black
      castling   = self.castling.split('') - ['-']
      en_passant = self.en_passant == '-' ? nil : en_passant

      PGN::Position.new(
        self.board,
        player,
        castling:   castling,
        en_passant: en_passant,
        halfmove:   self.halfmove.to_i,
        fullmove:   self.fullmove.to_i,
      )
    end

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
