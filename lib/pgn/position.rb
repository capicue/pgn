module PGN
  # This class is essentially a wrapper around a {PGN::FEN} object that
  # feels like a notation-independent chess position.
  #
  class Position
    extend Forwardable

    attr_accessor :fen
    def_delegators :@fen, :active,     :active=
    def_delegators :@fen, :squares,    :squares=
    def_delegators :@fen, :castling,   :castling=
    def_delegators :@fen, :en_passant, :en_passant=
    def_delegators :@fen, :halfmove,   :halfmove=
    def_delegators :@fen, :fullmove,   :fullmove=

    SQUARE_REGEX = %r{[a-h][1-8]}

    PLAYERS = ['w', 'b']

    UNICODE_PIECES = {
      'k' => "\u{265A}",
      'q' => "\u{265B}",
      'r' => "\u{265C}",
      'b' => "\u{265D}",
      'n' => "\u{265E}",
      'p' => "\u{265F}",
      'K' => "\u{2654}",
      'Q' => "\u{2655}",
      'R' => "\u{2656}",
      'B' => "\u{2657}",
      'N' => "\u{2658}",
      'P' => "\u{2659}",
      '_' => '_',
    }

    def self.start
      PGN::FEN.new.to_position
    end

    # @param fen [PGN::FEN] a fen object for the current position
    #
    def initialize(fen)
      fen = PGN::FEN.new(fen) if fen.is_a? String
      self.fen = fen
    end

    def move(str)
      move       = PGN::Move.new(str, self.active)
      calculator = PGN::MoveCalculator.new(self, move)

      result = self.dup

      result.squares    = calculator.new_squares
      result.castling   = calculator.castling
      result.en_passant = calculator.en_passant
      result.halfmove   = calculator.halfmove.to_s
      result.fullmove   = calculator.fullmove.to_s
      result.active     = calculator.active

      result
    end

    def dup
      PGN::Position.new(self.fen.dup)
    end

    def display_squares
      self.squares.map(&:reverse).transpose.map {|row| row.map {|e| e.nil? ? "_" : e } }
    end

    def inspect
      "\n" + self.display_squares.map {|s| s.map{|chr| UNICODE_PIECES[chr] }.join(' ') }.join("\n")
    end

  end
end
