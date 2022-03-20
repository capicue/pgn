# frozen_string_literal: true

require_relative './base'

module PGN
  # {PGN::Move} knows how to parse a move string in standard algebraic
  # notation to extract all relevant information.
  #
  # @see http://en.wikipedia.org/wiki/Algebraic_notation_(chess) Standard
  #   Algebraic Notation
  #
  # @!attribute san
  #   @return [String] the move string
  #   @example
  #     move1.san #=> "O-O-O+"
  #     move2.san #=> "Raxe1"
  #     move3.san #=> "e8=Q#"
  #
  # @!attribute player
  #   @return [Symbol] the current player
  #   @example
  #     move.player #=> :white
  #
  # @!attribute piece
  #   @return [String, nil] the piece being moved
  #   @example
  #     move1.piece #=> "Q"
  #     move2.piece #=> "r"
  #   @note this is nil for castling
  #   @note uppercase represents white, lowercase represents black
  #
  # @!attribute destination
  #   @return [String, nil] the destination square of the piece
  #   @example
  #     move.destination #=> "e4"
  #
  # @!attribute promotion
  #   @return [String, nil] the promotion piece, if applicable
  #
  # @!attribute check
  #   @return [String, nil] whether the move results in check or mate
  #   @example
  #     move1.check #=> "+"
  #     move2.check #=> "#"
  #
  # @!attribute capture
  #   @return [String, nil] whether the move is a capture
  #   @example
  #     move.capture #=> "x"
  #
  # @!attribute disambiguation
  #   @return [String, nil] the disambiguation string if there is one
  #   @example
  #     move.disambiguation #=> "3"
  #
  # @!attribute castle
  #   @return [String, nil] the castle string if applicable
  #   @example
  #     move1.castle #=> "O-O-O"
  #     move2.castle #=> "O-O"
  #
  class Move
    attr_accessor :san, :player, :piece, :destination, :promotion, :check, :capture, :disambiguation, :castle

    # A regular expression for matching moves in standard algebraic
    # notation
    #
    SAN_REGEX = /
      (?<piece>          [BKNQR]      ){0}
      (?<destination>    [a-h][1-8]   ){0}
      (?<promotion>      =[BNQR]      ){0}
      (?<check>          [#+]         ){0}
      (?<capture>        x            ){0}
      (?<disambiguation> [a-h]?[1-8]? ){0}

      (?<castle>         O-O(-O)?     ){0}

      (?<normal>
        \g<piece>?
        \g<disambiguation>
        \g<capture>?
        \g<destination>
        \g<promotion>?
      ){0}

      \A (\g<castle> | \g<normal>) \g<check>? \z
    /x

    # @param move [String] the move in SAN
    # @param player [Symbol] the player making the move
    # @example
    #   PGN::Move.new("e4", :white)
    #
    def initialize(move, player)
      self.player = player
      self.san    = move

      match = move.match(SAN_REGEX)

      match.names.each do |name|
        send("#{name}=", match[name]) if respond_to?(name)
      end
    end

    def piece=(val)
      return if san.match?(PGN::CODE[:castling][:kingside])

      @piece = (val || PGN::CODE[:piece][:P]).send(black? ? :downcase : :itself)
    end

    def promotion=(val)
      val && black? && @promotion = val.downcase.delete('=')
    end

    def capture=(val)
      @capture = !!val
    end

    def disambiguation=(val)
      @disambiguation = (val.to_s.empty? ? nil : val)
    end

    def castle=(val)
      return unless val

      @castle = case val
                when PGN::CODE[:castling][:kingside]  then PGN::CODE[:piece][:K]
                when PGN::CODE[:castling][:queenside] then PGN::CODE[:piece][:Q]
      end.send(black? ? :downcase : :itself)
    end

    # @return [Boolean] whether the move results in check
    #
    def check?
      check == PGN::CODE[:check]
    end

    # @return [Boolean] whether the move results in checkmate
    #
    def checkmate?
      check == PGN::CODE[:checkmate]
    end

    # @return [Boolean] whether it's white's turn
    #
    def white?
      player == :white
    end

    # @return [Boolean] whether it's black's turn
    #
    def black?
      player == :black
    end

    # @return [Boolean] whether the piece being moved is a pawn
    #
    def pawn?
      PGN::CODE[:pawns].include? piece
    end
  end
end
