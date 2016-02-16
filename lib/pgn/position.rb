module PGN
  # {PGN::Position} encapsulates all of the information necessary to
  # completely understand a chess position. It can be turned into a FEN string
  # or perform a move.
  #
  # @!attribute board
  #   @return [PGN::Board] the board for the position
  #
  # @!attribute player
  #   @return [Symbol] the player who moves next
  #   @example
  #     position.player #=> :white
  #
  # @!attribute castling
  #   @return [Array<String>] the castling moves that are still available
  #   @example
  #     position.castling #=> ["K", "k", "q"]
  #
  # @!attribute en_passant
  #   @return [String] the en passant square if applicable
  #
  # @!attribute halfmove
  #   @return [Integer] the number of halfmoves since the last pawn move or
  #     capture
  #
  # @!attribute fullmove
  #   @return [Integer] the number of fullmoves made so far
  #
  class Position
    PLAYERS  = [:white, :black]
    CASTLING = %w{K Q k q}

    attr_accessor :board
    attr_accessor :player
    attr_accessor :castling
    attr_accessor :en_passant
    attr_accessor :halfmove
    attr_accessor :fullmove

    # @return [PGN::Position] the starting position of a chess game
    #
    def self.start
      PGN::Position.new(
        PGN::Board.start,
        PLAYERS.first,
      )
    end

    # @param board [PGN::Board] the board for the position
    # @param player [Symbol] the player who moves next
    # @param castling [Array<String>] the castling moves that are still
    #   available
    # @param en_passant [String, nil] the en passant square if applicable
    # @param halfmove [Integer] the number of halfmoves since the last pawn
    #   move or capture
    # @param fullmove [Integer] the number of fullmoves made so far
    #
    # @example
    #   PGN::Position.new(
    #     PGN::Board.start,
    #     :white,
    #   )
    #
    def initialize(board, player, castling = CASTLING, en_passant = nil, halfmove = 0, fullmove = 1)
      self.board      = board
      self.player     = player
      self.castling   = castling
      self.en_passant = en_passant
      self.halfmove   = halfmove
      self.fullmove   = fullmove
    end 

    # @param str [String] the move to make in SAN
    # @return [PGN::Position] the resulting position
    #
    # @example
    #   queens_pawn = PGN::Position.start.move("d4")
    #
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
        new_castling,
        calculator.en_passant_square,
        new_halfmove,
        new_fullmove,
      )
    end

    # @return [Symbol] the next player to move
    #
    def next_player
      (PLAYERS - [self.player]).first
    end

    def inspect
      "\n" + self.board.inspect
    end

    # @return [PGN::FEN] a {PGN::FEN} object representing the current position
    #
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
