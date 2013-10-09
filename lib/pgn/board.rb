module PGN
  # {PGN::Board} represents the squares of a chess board and the pieces on
  # each square. It is responsible for translating between a human readable
  # format (white queen's rook on the bottom left) and the obvious
  # internal representation (white queen's rook is position [0,0]). It
  # takes care of converting square names (e4) to actual locations, and
  # can convert to unicode chess pieces for display purposes.
  #
  # @!attribute squares
  #   @return [Array<Array<String>>] the pieces on the board
  #
  class Board
    # The starting, internal representation of a chess board
    #
    START = [
      ["R", "P", nil, nil, nil, nil, "p", "r"],
      ["N", "P", nil, nil, nil, nil, "p", "n"],
      ["B", "P", nil, nil, nil, nil, "p", "b"],
      ["Q", "P", nil, nil, nil, nil, "p", "q"],
      ["K", "P", nil, nil, nil, nil, "p", "k"],
      ["B", "P", nil, nil, nil, nil, "p", "b"],
      ["N", "P", nil, nil, nil, nil, "p", "n"],
      ["R", "P", nil, nil, nil, nil, "p", "r"],
    ]

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

    # algebraic to unicode piece lookup
    #
    UNICODE_PIECES = {
      'k' => "\u{265A}",
      'q' => "\u{265B}",
      'r' => "\u{265C}",
      'b' => "\u{265D}",
      'n' => "\u{265E}",
      'p' => "\u{265F}",
      'K' => "\u{2654}",
      'Q' => "\u{2655}",
      'R' => "\u{2656}",
      'B' => "\u{2657}",
      'N' => "\u{2658}",
      'P' => "\u{2659}",
      nil => '_',
    }

    attr_accessor :squares

    # @return [PGN::Board] a board in the starting position
    #
    def self.start
      PGN::Board.new(START)
    end

    # @param squares [<Array<Array<String>>>] the squares of the board
    # @example
    #   PGN::Board.new(
    #     [
    #       ["R", "P", nil, nil, nil, nil, "p", "r"],
    #       ["N", "P", nil, nil, nil, nil, "p", "n"],
    #       ["B", "P", nil, nil, nil, nil, "p", "b"],
    #       ["Q", "P", nil, nil, nil, nil, "p", "q"],
    #       ["K", "P", nil, nil, nil, nil, "p", "k"],
    #       ["B", "P", nil, nil, nil, nil, "p", "b"],
    #       ["N", "P", nil, nil, nil, nil, "p", "n"],
    #       ["R", "P", nil, nil, nil, nil, "p", "r"],
    #     ]
    #   )
    #
    def initialize(squares)
      self.squares = squares
    end

    # @overload at(str)
    #   Looks up a piece based on the string representation of a square (e4)
    #   @param str [String] the square in algebraic notation
    # @overload at(file, rank)
    #   Looks up a piece based on zero-indexed coordinates (4, 3)
    #   @param file [Integer] the file the piece is on
    #   @param rank [Integer] the rank the piece is on
    # @return [String, nil] the piece on the square, or nil if it is
    #   empty
    # @example
    #   board.at(4,3)  #=> "P"
    #   board.at("e4") #=> "P"
    #
    def at(*args)
      case args.length
      when 1
        self.at(*coordinates_for(args.first))
      when 2
        self.squares[args[0]][args[1]]
      end
    end

    # @param changes [Hash<String, <String, nil>>] changes to make to the board
    # @return [self]
    # @example
    #   board.change!({"e2" => nil, "e4" => "P"})
    #
    def change!(changes)
      changes.each do |square, piece|
        self.update(square, piece)
      end
      self
    end

    # @param square [String] the square in algebraic notation
    # @param piece [String, nil] the piece to put on the square
    # @return [self]
    # @example
    #   board.update("e4", "P")
    #
    def update(square, piece)
      coords = coordinates_for(square)
      self.squares[coords[0]][coords[1]] = piece
      self
    end

    # @param position [String] the square in algebraic notation
    # @return [Array<Integer>] the coordinates of the square
    # @example
    #   board.coordinates_for("e4") #=> [4, 3]
    #
    def coordinates_for(position)
      file_chr, rank_chr = position.chars
      file = FILE_TO_INDEX[file_chr]
      rank = RANK_TO_INDEX[rank_chr]
      [file, rank]
    end

    # @param coordinates [Array<Integer>] the coordinates of the square
    # @return [String] the square in algebraic notation
    # @example
    #   board.position_for([4, 3]) #=> "e4"
    #
    def position_for(coordinates)
      file, rank = coordinates
      file_chr = INDEX_TO_FILE[file]
      rank_chr = INDEX_TO_RANK[rank]
      [file_chr, rank_chr].join('')
    end

    # @return [String] the board in human readable format with unicode
    #   pieces
    #
    def inspect
      self.squares.transpose.reverse.map do |row|
        row.map{|chr| UNICODE_PIECES[chr] }.join(' ')
      end.join("\n")
    end

    # @return [PGN::Board] a copy of self with duplicated squares
    #
    def dup
      PGN::Board.new(self.squares.map(&:dup))
    end

  end
end
