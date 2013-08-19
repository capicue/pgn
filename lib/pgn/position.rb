module PGN
  class Position
    SQUARE_REGEX = %r{[a-h][1-8]}

    attr_accessor :board, :active, :castling, :en_passant, :halfmove, :fullmove

    def self.start
      PGN::FEN.new.to_position
    end

    def initialize(board, active, castling, en_passant, halfmove, fullmove)
      self.board      = PGN::Board.new(board)
      self.active     = active
      self.castling   = castling
      self.en_passant = en_passant
      self.halfmove   = halfmove
      self.fullmove   = fullmove
    end

    def dup
      PGN::Position.new(self.board.squares, self.active, self.castling, self.en_passant, self.halfmove, self.fullmove)
    end

    def to_fen
      fen_parts = [
        self.board.to_fen_str,
        self.active,
        self.castling,
        self.en_passant,
        self.halfmove,
        self.fullmove,
      ]

      PGN::FEN.new(fen_parts.join(' '))
    end

    def inspect
      self.board.inspect
    end

    def move(str)
      str, check = str.partition('+')
      str, mate  = str.partition('#')

      if str[0] == 'O'
        self.board.castle(str, self.active)
      else
        str,   promoted    = str.split("=")
        str,   destination = str.partition(SQUARE_REGEX)
        str,   capture     = str.partition("x")
        piece, specifier   = str.partition(%r{[a-h]|[1-8]})

        check   = !check.empty?
        mate    = !mate.empty?
        capture = !capture.empty?

        specifier = specifier.empty? ? nil : specifier
        piece     = piece.empty?     ? "P" : piece
        piece.downcase! if self.active == 'b'

        origin = self.board.compute_origin(
          piece,
          destination,
          specifier,
          capture,
        )

        self.board.move(origin, destination, piece, promoted)
      end

      flip_active

      self
    end

    private

    def flip_active
      if self.active == 'w'
        self.active = 'b'
      else
        self.active = 'w'
      end
    end
  end
end
