# frozen_string_literal: true

require_relative './base'

module PGN
  # {PGN::MoveCalculator} is responsible for computing all of the ways that a
  # specific move changes the current position. This includes which squares on
  # the board need to be updated, new castling restrictions, the en passant
  # square and whether to update fullmove and halfmove counters.
  #
  # @!attribute board
  #   @return [PGN::Board] the current board
  #
  # @!attribute move
  #   @return [PGN::Move] the current move
  #
  # @!attribute origin
  #   @return [String, nil] the origin square in SAN
  #
  class MoveCalculator
    # Specifies the movement of pieces who are allowed to move in a
    # given direction until they reach an obstacle or the end of the
    # board.
    #
    DIRECTIONS = {
      PGN::CODE[:piece][:b] => [[1, 1], [-1, 1], [-1, -1], [1, -1]],
      PGN::CODE[:piece][:r] => [[-1, 0], [1, 0], [0, -1], [0, 1]],
      PGN::CODE[:piece][:q] => [[1, 1], [-1, 1], [-1, -1], [1, -1], [-1, 0], [1, 0], [0, -1], [0, 1]]
    }

    # Specifies the movement of pieces that have a limited set of moves
    # they are allowed to make.
    #
    MOVES = {
      PGN::CODE[:piece][:k] => [[-1, -1], [0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0]],
      PGN::CODE[:piece][:n] => [[-1, -2], [-1, 2], [1, -2], [1, 2], [-2, -1], [2, -1], [-2, 1], [2, 1]]
    }

    # Specifies possible pawn movements. It may seem backwards since it is
    # used to compute the origin square and not the destination.
    #
    PAWN_MOVES = {
      PGN::CODE[:piece][:P] => {
        capture: [[-1, -1], [1, -1]],
        normal: [[0, -1]],
        double: [[0, -2]]
      },
      PGN::CODE[:piece][:p] => {
        capture: [[-1, 1], [1, 1]],
        normal: [[0,  1]],
        double: [[0,  2]]
      }
    }

    # The squares to update for each possible castling move.
    #
    CASTLING = {
      PGN::CODE[:piece][:Q] => {
        'a1' => nil,
        'c1' => PGN::CODE[:piece][:K],
        'd1' => PGN::CODE[:piece][:R],
        'e1' => nil
      },
      PGN::CODE[:piece][:K] => {
        'e1' => nil,
        'f1' => PGN::CODE[:piece][:R],
        'g1' => PGN::CODE[:piece][:K],
        'h1' => nil
      },
      PGN::CODE[:piece][:q] => {
        'a8' => nil,
        'c8' => PGN::CODE[:piece][:k],
        'd8' => PGN::CODE[:piece][:r],
        'e8' => nil
      },
      PGN::CODE[:piece][:k] => {
        'e8' => nil,
        'f8' => PGN::CODE[:piece][:r],
        'g8' => PGN::CODE[:piece][:k],
        'h8' => nil
      }
    }

    attr_accessor :board, :move, :origin

    # @param board [PGN::Board] the current board
    # @param move [PGN::Move] the current move
    #
    def initialize(board, move)
      self.board  = board
      self.move   = move
      self.origin = compute_origin
    end

    # @return [PGN::Board] the board after the move is made
    #
    def result_board
      board.dup.change!(changes)
    end

    # @return [Array<String>] which castling moves are no longer available
    #
    def castling_restrictions
      restrict = []

      # when a king or rook is moved
      case move.piece
      when PGN::CODE[:piece][:k] then restrict += PGN::CODE[:rulers][:black]
      when PGN::CODE[:piece][:K] then restrict += PGN::CODE[:rulers][:white]
      when PGN::CODE[:piece][:R]
        restrict << {
          'a1' => PGN::CODE[:piece][:Q],
          'h1' => PGN::CODE[:piece][:K]
        }[origin]
      when PGN::CODE[:piece][:r]
        restrict << {
          'a8' => PGN::CODE[:piece][:q],
          'h8' => PGN::CODE[:piece][:k]
        }[origin]
      end

      # when castling occurs
      restrict += PGN::CODE[:rulers][:black] if PGN::CODE[:rulers][:black].include? move.castle
      restrict += PGN::CODE[:rulers][:white] if PGN::CODE[:rulers][:white].include? move.castle

      # when a rook is taken
      restrict << PGN::CODE[:piece][:k] if move.destination == 'h8'
      restrict << PGN::CODE[:piece][:q] if move.destination == 'a8'
      restrict << PGN::CODE[:piece][:K] if move.destination == 'h1'
      restrict << PGN::CODE[:piece][:Q] if move.destination == 'a1'
      restrict.compact.uniq
    end

    # @return [Boolean] whether to increment the halfmove clock
    #
    def increment_halfmove?
      !(move.capture || move.pawn?)
    end

    # @return [Boolean] whether to increment the fullmove counter
    #
    def increment_fullmove?
      move.black?
    end

    # @return [String, nil] the en passant square if applicable
    #
    def en_passant_square
      return nil if move.castle
      return unless move.pawn? && (origin[1].to_i - move.destination[1].to_i).abs == 2

      origin[0] + (move.white? ? '3' : '6')
    end

    private

      def changes
        changes = {}
        changes.merge!(CASTLING[move.castle]) if move.castle
        changes.merge!(
          origin => nil,
          move.destination => move.piece,
          en_passant_capture => nil
        )
        changes[move.destination] = move.promotion if move.promotion
        changes.reject! { |key, _| key.nil? or key.empty? }

        changes
      end

      # Using the current position and move, figure out where the piece
      # came from.
      #
      def compute_origin
        return nil if move.castle

        possible = case move.piece
                   when /[brq]/i then direction_origins
                   when /[kn]/i  then move_origins
                   when /p/i     then pawn_origins
        end
        possible = disambiguate(possible) if possible.length > 1

        board.position_for(possible.first)
      end

      # From the destination square, move in each direction stopping if we
      # reach the end of the board. If we encounter a piece, add it to the
      # list of origin possible if it is the moving piece, or else
      # check the next direction.
      #
      def direction_origins
        directions = DIRECTIONS[move.piece.downcase]
        possible = []

        directions.each do |dir|
          piece, square = first_piece(destination_coords, dir)
          possible << square if piece == move.piece
        end

        possible
      end

      # From the destination square, make each move. If it is a valid
      # square and matches the moving piece, add it to the list of origin
      # possible.
      #
      def move_origins(moves = nil)
        moves ||= MOVES[move.piece.downcase]
        possible = []
        file, rank = destination_coords

        moves.each do |i, j|
          f = file + i
          r = rank + j

          possible << [f, r] if valid_square?(f, r) && board.at(f, r) == move.piece
        end

        possible
      end

      # Computes the possbile pawn origins based on the destination square
      # and whether or not the move is a capture.
      #
      def pawn_origins
        _, rank     = destination_coords
        double_rank = (rank == 3 && move.white?) || (rank == 4 && move.black?)

        pawn_moves = PAWN_MOVES[move.piece]

        moves = move.capture ? pawn_moves[:capture] : pawn_moves[:normal]
        moves += pawn_moves[:double] if double_rank

        move_origins(moves)
      end

      def disambiguate(possible)
        possible = disambiguate_san(possible)
        return possible unless possible.length > 1

        possible = disambiguate_pawns(possible)
        possible = disambiguate_discovered_check(possible)
      end

      # Try to disambiguate based on the standard algebraic notation.
      #
      def disambiguate_san(possible)
        return possible unless move.disambiguation

        possible.select { |p| board.position_for(p).match(move.disambiguation) }
      end

      # A pawn can't move two spaces if there is a pawn in front of it.
      #
      def disambiguate_pawns(possible)
        return possible unless move.piece.match(/p/i) && !move.capture

        possible.reject { |p| board.position_for(p).match(/2|7/) }
      end

      # A piece can't move if it would result in a discovered check.
      #
      def disambiguate_discovered_check(possible)
        DIRECTIONS.each do |attacking_piece, directions|
          attacking_piece = attacking_piece.upcase if move.black?

          directions.each do |dir|
            piece, square = first_piece(king_position, dir)
            next unless piece == move.piece && possible.include?(square)

            piece, = first_piece(square, dir)
            possible.reject! { |p| p == square } if piece == attacking_piece
          end
        end

        possible
      end

      def first_piece(from, direction)
        file, rank = from
        i,    j    = direction
        piece = nil

        while valid_square?(file += i, rank += j)
          break if piece = board.at(file, rank)
        end

        [piece, [file, rank]]
      end

      # If the move is a capture and there is no piece on the
      # destination square, it must be an en passant capture.
      #
      def en_passant_capture
        return nil if move.castle

        move.destination[0] + origin[1] if !board.at(move.destination) && move.capture
      end

      def king_position
        king = move.white? ? PGN::CODE[:piece][:K] : PGN::CODE[:piece][:k]

        coords = nil
        (0..7).map do |file|
          (0..7).map do |rank|
            coords = [file, rank] if board.at(file, rank) == king
          end
        end

        coords
      end

      def valid_square?(file, rank)
        (0..7).include?(file) && (0..7).include?(rank)
      end

      def destination_coords
        board.coordinates_for(move.destination)
      end
  end
end
