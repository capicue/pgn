# frozen_string_literal: true

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
    CASTLING = PGN::CODE[:rulers][:white] + PGN::CODE[:rulers][:black]
    attr_accessor :board, :player, :castling, :en_passant, :halfmove, :fullmove

    # @return [PGN::Position] the starting position of a chess game
    #
    def self.start
      PGN::Position.new(
        PGN::Board.start,
        PGN::CODE[:players].first
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
      self.castling   = castling
      self.en_passant = en_passant
      self.fullmove   = fullmove
      self.halfmove   = halfmove
      self.player     = player
    end

    # @param str [String] the move to make in SAN
    # @return [PGN::Position] the resulting position
    #
    # @example
    #   queens_pawn = PGN::Position.start.move("d4")
    #
    def move(str)
      move       = PGN::Move.new(str, player)
      calculator = PGN::MoveCalculator.new(board, move)

      new_castling = castling - calculator.castling_restrictions
      new_halfmove = (calculator.increment_halfmove? ? (halfmove + 1) : 0)
      new_fullmove = fullmove + (calculator.increment_fullmove? ? 1 : 0)

      PGN::Position.new(
        calculator.result_board,
        next_player,
        new_castling,
        calculator.en_passant_square,
        new_halfmove,
        new_fullmove
      )
    end

    # @return [Symbol] the next player to move
    #
    def next_player
      (PGN::CODE[:players] - [player]).first
    end

    def inspect
      "\n" + board.inspect
    end

    # @return [PGN::FEN] a {PGN::FEN} object representing the current position
    #
    def to_fen
      PGN::FEN.from_attributes(
        board: board,
        active: PGN::CODE[:color][player],
        castling: castling.join,
        en_passant: en_passant,
        halfmove: halfmove.to_s,
        fullmove: fullmove.to_s
      )
    end
  end
end
