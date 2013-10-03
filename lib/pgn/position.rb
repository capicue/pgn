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
      move = PGN::Move.new(str)

      if move.castle
        self.board.castle(move.castle, self.active)
      else
        piece = move.piece
        piece.downcase! if self.active == 'b'

        origin = self.board.compute_origin(
          piece,
          move.destination,
          move.disambiguation,
          move.capture,
        )

        self.board.move(
          origin,
          move.destination,
          piece,
          move.promotion
        )
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
