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
      'b' => [[ 1,  1], [-1,  1], [-1, -1], [ 1, -1]],
      'r' => [[-1,  0], [ 1,  0], [ 0, -1], [ 0,  1]],
      'q' => [[ 1,  1], [-1,  1], [-1, -1], [ 1, -1],
              [-1,  0], [ 1,  0], [ 0, -1], [ 0,  1]],
    }

    # Specifies the movement of pieces that have a limited set of moves
    # they are allowed to make.
    #
    MOVES = {
      'k' => [[-1, -1], [ 0, -1], [ 1, -1], [ 1,  0],
              [ 1,  1], [ 0,  1], [-1,  1], [-1,  0]],
      'n' => [[-1, -2], [-1,  2], [ 1, -2], [ 1,  2],
              [-2, -1], [ 2, -1], [-2,  1], [ 2,  1]],
    }

    # Specifies possible pawn movements. It may seem backwards since it is
    # used to compute the origin square and not the destination.
    #
    PAWN_MOVES = {
      'P' => {
        capture: [[-1, -1], [ 1, -1]],
        normal:  [[ 0, -1]],
        double:  [[ 0, -2]],
      },
      'p' => {
        capture: [[-1,  1], [ 1,  1]],
        normal:  [[ 0,  1]],
        double:  [[ 0,  2]],
      },
    }

    # The squares to update for each possible castling move.
    #
    CASTLING = {
      "Q" => {
        "a1" => nil,
        "c1" => "K",
        "d1" => "R",
        "e1" => nil,
      },
      "K" => {
        "e1" => nil,
        "f1" => "R",
        "g1" => "K",
        "h1" => nil,
      },
      "q" => {
        "a8" => nil,
        "c8" => "k",
        "d8" => "r",
        "e8" => nil,
      },
      "k" => {
        "e8" => nil,
        "f8" => "r",
        "g8" => "k",
        "h8" => nil,
      },
    }

    attr_accessor :board
    attr_accessor :move
    attr_accessor :origin

    # @param board [PGN::Board] the current board
    # @param move [PGN::Move] the current move
    #
    def initialize(board, move)
      self.board = board
      self.move  = move
      self.origin = compute_origin
    end

    # @return [PGN::Board] the board after the move is made
    #
    def result_board
      new_board = self.board.dup
      new_board.change!(changes)

      new_board
    end

    # @return [Array<String>] which castling moves are no longer available
    #
    def castling_restrictions
      restrict = case self.move.piece
      when "K" then "KQ"
      when "k" then "kq"
      when "R"
        {"a1" => "Q", "h1" => "K"}[self.origin]
      when "r"
        {"a8" => "q", "h8" => "k"}[self.origin]
      end

      restrict = "KQ" if ['K', 'Q'].include? move.castle
      restrict = "kq" if ['k', 'q'].include? move.castle
      
      restrict += 'Q' if self.move.destination == 'a1' && !restrict.include?('Q')
      restrict += 'q' if self.move.destination == 'a8' && !restrict.include?('q')
      restrict += 'K' if self.move.destination == 'h1' && !restrict.include?('K')
      restrict += 'k' if self.move.destination == 'h8' && !restrict.include?('k')

      restrict ||= ''

      restrict.split('')
    end

    # @return [Boolean] whether to increment the halfmove clock
    #
    def increment_halfmove?
      !(self.move.capture || self.move.pawn?)
    end

    # @return [Boolean] whether to increment the fullmove counter
    #
    def increment_fullmove?
      self.move.black?
    end

    # @return [String, nil] the en passant square if applicable
    #
    def en_passant_square
      return nil if move.castle

      if self.move.pawn? && (self.origin[1].to_i - self.move.destination[1].to_i).abs == 2
        self.move.white? ?
          self.origin[0] + '3' :
          self.origin[0] + '6'
      end
    end

    private

    def changes
      changes = {}
      changes.merge!(CASTLING[self.move.castle]) if self.move.castle
      changes.merge!(
        self.origin           => nil,
        self.move.destination => self.move.piece,
        en_passant_capture    => nil,
      )
      if self.move.promotion
        changes[self.move.destination] = self.move.promotion
      end

      changes.reject! {|key, _| key.nil? }

      changes
    end

    # Using the current position and move, figure out where the piece
    # came from.
    #
    def compute_origin
      return nil if move.castle

      possibilities = case move.piece
      when /[brq]/i then direction_origins
      when /[kn]/i  then move_origins
      when /p/i     then pawn_origins
      end

      if possibilities.length > 1
        possibilities = disambiguate(possibilities)
      end

      self.board.position_for(possibilities.first)
    end

    # From the destination square, move in each direction stopping if we
    # reach the end of the board. If we encounter a piece, add it to the
    # list of origin possibilities if it is the moving piece, or else
    # check the next direction.
    #
    def direction_origins
      directions    = DIRECTIONS[move.piece.downcase]
      possibilities = []

      directions.each do |dir|
        piece, square = first_piece(destination_coords, dir)
        possibilities << square if piece == self.move.piece
      end

      possibilities
    end

    # From the destination square, make each move. If it is a valid
    # square and matches the moving piece, add it to the list of origin
    # possibilities.
    #
    def move_origins(moves = nil)
      moves         ||= MOVES[move.piece.downcase]
      possibilities   = []
      file, rank      = destination_coords

      moves.each do |i, j|
        f = file + i
        r = rank + j

        if valid_square?(f, r) && self.board.at(f, r) == move.piece
          possibilities << [f, r]
        end
      end

      possibilities
    end

    # Computes the possbile pawn origins based on the destination square
    # and whether or not the move is a capture.
    #
    def pawn_origins
      _, rank     = destination_coords
      double_rank = (rank == 3 && self.move.white?) || (rank == 4 && self.move.black?)

      pawn_moves = PAWN_MOVES[self.move.piece]

      moves = self.move.capture ? pawn_moves[:capture] : pawn_moves[:normal]
      moves += pawn_moves[:double] if double_rank

      move_origins(moves)
    end

    def disambiguate(possibilities)
      possibilities = disambiguate_san(possibilities)
      possibilities = disambiguate_pawns(possibilities)            if possibilities.length > 1
      possibilities = disambiguate_discovered_check(possibilities) if possibilities.length > 1

      possibilities
    end

    # Try to disambiguate based on the standard algebraic notation.
    #
    def disambiguate_san(possibilities)
      move.disambiguation ?
        possibilities.select {|p| self.board.position_for(p).match(move.disambiguation) } :
        possibilities
    end

    # A pawn can't move two spaces if there is a pawn in front of it.
    #
    def disambiguate_pawns(possibilities)
      self.move.piece.match(/p/i) && !self.move.capture ?
        possibilities.reject {|p| self.board.position_for(p).match(/2|7/) } :
        possibilities
    end

    # A piece can't move if it would result in a discovered check.
    #
    def disambiguate_discovered_check(possibilities)
      DIRECTIONS.each do |attacking_piece, directions|
        attacking_piece = attacking_piece.upcase if self.move.black?

        directions.each do |dir|
          piece, square = first_piece(king_position, dir)
          next unless piece == self.move.piece && possibilities.include?(square)

          piece, _ = first_piece(square, dir)
          possibilities.reject! {|p| p == square } if piece == attacking_piece
        end
      end

      possibilities
    end

    def first_piece(from, direction)
      file, rank = from
      i,    j    = direction

      piece = nil

      while valid_square?(file += i, rank += j)
        break if piece = self.board.at(file, rank)
      end

      [piece, [file, rank]]
    end

    # If the move is a capture and there is no piece on the
    # destination square, it must be an en passant capture.
    #
    def en_passant_capture
      return nil if self.move.castle

      if !self.board.at(self.move.destination) && self.move.capture
        self.move.destination[0] + self.origin[1]
      end
    end

    def king_position
      king = self.move.white? ? 'K' : 'k'

      coords = nil
      0.upto(7) do |file|
        0.upto(7) do |rank|
          if self.board.at(file, rank) == king
            coords = [file, rank]
          end
        end
      end

      coords
    end

    def valid_square?(file, rank)
      (0..7) === file && (0..7) === rank
    end

    def destination_coords
      self.board.coordinates_for(self.move.destination)
    end

  end
end
