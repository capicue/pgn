module PGN
  class Position
    PLAYERS  = [:white, :black]
    CASTLING = %w{K Q k q}

    attr_accessor :board
    attr_accessor :player
    attr_accessor :castling
    attr_accessor :en_passant
    attr_accessor :halfmove
    attr_accessor :fullmove

    def self.start
      PGN::Position.new(
        PGN::Board.start,
        PLAYERS.first,
        castling: CASTLING,
        en_passant: nil,
        halfmove: 0,
        fullmove: 0,
      )
    end

    def initialize(board, player, castling: [], en_passant: nil, halfmove: 0, fullmove: 0)
      self.board      = board
      self.player     = player
      self.castling   = castling
      self.en_passant = en_passant
      self.halfmove   = halfmove
      self.fullmove   = fullmove
    end 

    def move(str)
      move       = PGN::Move.new(str, self.player)
      calculator = PGN::MoveCalculator.new(self.board, move)

      new_castling = self.castling - calculator.castling_restrictions
      new_halfmove = calculator.increment_halfmove? ?
        self.halfmove + 1 :
        0
      new_fullmove = calculator.increment_fullmove? ?
        self.fullmove + 1 :
        self.fullmove

      PGN::Position.new(
        calculator.result_board,
        self.next_player,
        castling:   new_castling,
        en_passant: calculator.en_passant_square,
        halfmove:   new_halfmove,
        fullmove:   new_fullmove,
      )
    end

    def next_player
      (PLAYERS - [self.player]).first
    end

    def inspect
      "\n" + self.board.inspect
    end

    def to_fen
      PGN::FEN.from_attributes(
        board:      self.board,
        active:     self.player == :white ? 'w' : 'b',
        castling:   self.castling.join(''),
        en_passant: self.en_passant,
        halfmove:   self.halfmove.to_s,
        fullmove:   self.fullmove.to_s,
      )
    end

  end
end
