module PGN
  # This class is responsible for taking a position and a move and
  # figuring out which squares to update. This involves figuring out
  # where the moving piece came from. This class also needs to determine
  # how to update position states such as en passant, castling
  # availability, and move counters.
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

    attr_accessor :position, :move, :board
    attr_accessor :origin

    def initialize(position, move)
      self.position = position
      self.move     = move
      self.board    = position.board
    end

    # Determine where everything is in the board for the new position.
    #
    def new_board
      compute_origin

      new_board = self.board.dup
      new_board.change!(changes)

      new_board
    end

    def changes
      compute_origin

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

    # If the moving piece is a pawn and it moved two squares, the en
    # passant square is needed for FEN notation.
    #
    def en_passant
      compute_origin

      return nil if move.castle

      if self.move.piece.match(/p/i) && (self.origin[1].to_i - self.move.destination[1].to_i).abs == 2
        self.move.white? ?
          self.origin[0] + '3' :
          self.origin[0] + '6'
      end
    end

    # Determines which castling moves are still available based on the
    # rook and king movements.
    #
    def castling
      compute_origin

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

      castling = self.position.castling.dup
      castling = castling.delete(restrict) if restrict
      castling = "-" if castling.nil?
      castling
    end

    # The halfmove counter represents the number of halfmoves since the
    # last pawn advance or capture.
    #
    def halfmove
      self.move.capture || ['P', 'p'].include?(self.move.piece) ?
        0 :
        self.position.halfmove.to_i + 1
    end

    # The fullmove counter gets incremented after black plays.
    #
    def fullmove
      self.move.black? ?
        self.position.fullmove.to_i + 1 :
        self.position.fullmove.to_i
    end

    # The active player after the move is made.
    #
    def active
      self.move.white? ? 'b' : 'w'
    end

    private

    # Using the current position and move, figure out where the piece
    # came from.
    #
    def compute_origin
      return nil if move.castle

      @origin ||= begin
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
    end

    # From the destination square, move in each direction stopping if we
    # reach the end of the board. If we encounter a piece, add it to the
    # list of origin possibilities if it is the moving piece, or else
    # check the next direction.
    #
    def direction_origins
      directions    = DIRECTIONS[move.piece.downcase]
      possibilities = []

      directions.each do |i, j|
        file, rank = destination_coords

        while valid_square?(file += i, rank += j)
          piece = self.board.at(file, rank)
          possibilities << [file, rank] if piece == move.piece
          break if piece
        end
      end

      possibilities
    end

    # From the destination square, make each move. If it is a valid
    # square and matches the moving piece, add it to the list of origin
    # possibilities.
    #
    def move_origins
      moves         = MOVES[move.piece.downcase]
      possibilities = []
      file, rank    = destination_coords

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
      possibilities = []
      file, rank    = destination_coords

      dir = self.move.white? ? -1 : 1

      if self.move.capture
        possibilities += [[file - 1, rank + dir], [file + 1, rank + dir]]
      else
        en_passant = (rank == 3 && dir == -1) || (rank == 4 && dir == 1)

        possibilities << [file, rank + dir]
        possibilities << [file, rank + (2 * dir)] if en_passant
      end

      possibilities.select! {|p| valid_square?(*p) && self.board.at(*p) == self.move.piece }
      possibilities
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

        directions.each do |i, j|
          file, rank = king_position
          seen_moving_piece = false

          loop do
            file += i
            rank += j

            break unless valid_square?(file, rank)
            next  unless current_piece = self.board.at(file, rank)

            if seen_moving_piece
              current_piece == attacking_piece ?
                possibilities.reject! {|p| p == seen_moving_piece } :
                break
            else
              if current_piece == self.move.piece
                seen_moving_piece = [file, rank] if possibilities.include?([file, rank])
              else
                break
              end
            end
          end
        end
      end

      possibilities
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
