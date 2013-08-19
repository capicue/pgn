module PGN
  class Board
    FILE_TO_INDEX = {
      'a' => 0,
      'b' => 1,
      'c' => 2,
      'd' => 3,
      'e' => 4,
      'f' => 5,
      'g' => 6,
      'h' => 7,
    }
    INDEX_TO_FILE = Hash[FILE_TO_INDEX.map(&:reverse)]

    RANK_TO_INDEX = {
      '1' => 0,
      '2' => 1,
      '3' => 2,
      '4' => 3,
      '5' => 4,
      '6' => 5,
      '7' => 6,
      '8' => 7,
    }
    INDEX_TO_RANK = Hash[RANK_TO_INDEX.map(&:reverse)]

    KING_MOVES        = [[-1, -1], [ 0, -1], [ 1, -1], [ 1,  0], [ 1,  1], [ 0,  1], [-1,  1], [-1,  0]]
    KNIGHT_MOVES      = [[-1, -2], [-1,  2], [ 1, -2], [ 1,  2], [-2, -1], [ 2, -1], [-2,  1], [ 2,  1]]
    ROOK_DIRECTIONS   = [[-1,  0], [ 1,  0], [ 0, -1], [ 0,  1]]
    BISHOP_DIRECTIONS = [[ 1,  1], [-1,  1], [-1, -1], [ 1, -1]]
    QUEEN_DIRECTIONS  = ROOK_DIRECTIONS + BISHOP_DIRECTIONS

    beg = 0xe2.chr + 0x99.chr
    UNICODE = {
      'k' => beg + 0x9a.chr,
      'q' => beg + 0x9b.chr,
      'r' => beg + 0x9c.chr,
      'b' => beg + 0x9d.chr,
      'n' => beg + 0x9e.chr,
      'p' => beg + 0x9f.chr,
      'K' => beg + 0x94.chr,
      'Q' => beg + 0x95.chr,
      'R' => beg + 0x96.chr,
      'B' => beg + 0x97.chr,
      'N' => beg + 0x98.chr,
      'P' => beg + 0x99.chr,
      '_' => '_',
    }

    attr_accessor :squares

    def initialize(squares)
      self.squares = squares
    end

    def squares=(squares)
      @squares = squares.transpose.map(&:reverse)
    end

    def squares
      res = @squares.map(&:reverse).transpose
      res.map {|row| row.map {|r| r.nil? ? '_' : r } }
    end

    def to_fen_str
      self.squares.map do |row|
        row = row.map {|r| r.nil? ? '_' : r }
        row.join('').gsub(/_+/) {|match| match.length }
      end.join('/')
    end

    def move(origin, destination, piece, promoted = nil)
      origin      = self.coordinates_for(origin) unless origin.is_a?(Array)
      destination = self.coordinates_for(destination) unless destination.is_a?(Array)

      @squares[origin[0]][origin[1]] = nil
      @squares[destination[0]][destination[1]] = (promoted || piece)
    end

    def castle(str, active)
      case active
      when 'w'
        rank = 0
        king = 'K'
        rook = 'R'
      when 'b'
        rank = 7
        king = 'k'
        rook = 'r'
      end

      case str
      when 'O-O-O'
        @squares[0][rank] = nil
        @squares[2][rank] = king
        @squares[3][rank] = rook
        @squares[4][rank] = nil
      when 'O-O'
        @squares[4][rank] = nil
        @squares[5][rank] = rook
        @squares[6][rank] = king
        @squares[7][rank] = nil
      end
    end

    def coordinates_for(position)
      file_chr, rank_chr = position.chars
      file = FILE_TO_INDEX[file_chr]
      rank = RANK_TO_INDEX[rank_chr]
      [file, rank]
    end

    def position_for(coordinates)
      file, rank = coordinates
      file_chr = INDEX_TO_FILE[file]
      rank_chr = INDEX_TO_RANK[rank]
      [file_chr, rank_chr].join('')
    end

    def compute_origin(piece, destination, specifier = nil, capture = false)
      file, rank = self.coordinates_for(destination)

      possibilities = case piece
      when /p/i
        pawn_origins(piece, file, rank, capture)
      when /r/i
        direction_origins(ROOK_DIRECTIONS, piece, file, rank)
      when /n/i
        move_origins(KNIGHT_MOVES, piece, file, rank)
      when /b/i
        direction_origins(BISHOP_DIRECTIONS, piece, file, rank)
      when /q/i
        direction_origins(QUEEN_DIRECTIONS, piece, file, rank)
      when /k/i
        move_origins(KING_MOVES, piece, file, rank)
      end

      if possibilities.length > 1
        possibilities.select! {|p| self.position_for(p).match(specifier) }
      end

      raise if possibilities.length > 1
      possibilities.first
    end

    def pawn_origins(piece, file, rank, capture)
      possibilities = []

      case piece
      when 'P'
        dir = -1
        en_passant = (rank == 3)
      when 'p'
        dir = 1
        en_passant = (rank == 4)
      end

      if capture
        possibilities << [file - 1, rank + dir]
        possibilities << [file + 1, rank + dir]
      else
        possibilities << [file, rank + (2 * dir)] if en_passant
        possibilities << [file, rank + dir]
      end

      possibilities.select! {|p| self.valid_square?(*p) && self.at(*p) == piece }
      possibilities
    end

    def direction_origins(directions, piece, file, rank)
      possibilities = []
      directions.each do |i, j|
        f = file
        r = rank

        while self.valid_square?(f += i, r += j)
          if current_piece = self.at(f, r)
            possibilities << [f, r] if current_piece == piece
            break
          end
        end
      end
      possibilities
    end

    def move_origins(moves, piece, file, rank)
      possibilities = []
      moves.each do |i, j|
        f = file + i
        r = rank + j

        if self.valid_square?(f, r)
          possibilities << [f, r] if self.at(f, r) == piece
        end
      end
      possibilities
    end

    def at(file, rank)
      @squares[file][rank]
    end

    def valid_square?(file, rank)
      (0..7) === file && (0..7) === rank
    end

    def inspect
      "\n" + self.squares.map {|s| s.map{|chr| UNICODE[chr] }.join(' ') }.join("\n")
    end
  end
end
