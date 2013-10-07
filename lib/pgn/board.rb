module PGN
  class Board
    START = [
      ["R", "P", "_", "_", "_", "_", "p", "r"],
      ["N", "P", "_", "_", "_", "_", "p", "n"],
      ["B", "P", "_", "_", "_", "_", "p", "b"],
      ["Q", "P", "_", "_", "_", "_", "p", "q"],
      ["K", "P", "_", "_", "_", "_", "p", "k"],
      ["B", "P", "_", "_", "_", "_", "p", "b"],
      ["N", "P", "_", "_", "_", "_", "p", "n"],
      ["R", "P", "_", "_", "_", "_", "p", "r"],
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
      '_' => '_',
    }

    attr_accessor :squares

    def self.start
      PGN::Board.new(START)
    end

    def initialize(squares)
      self.squares = squares
    end

    def at(*args)
      str = case args.length
      when 1
        self.at(*coordinates_for(args.first))
      when 2
        self.squares[args[0]][args[1]]
      end

      str == "_" ? nil : str
    end

    def change!(changes)
      changes.each do |square, piece|
        self.update(square, piece)
      end
    end

    def update(square, piece)
      coords = coordinates_for(square)
      self.squares[coords[0]][coords[1]] = piece || "_"
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

    def inspect
      self.squares.transpose.reverse.map do |row|
        row.map{|chr| UNICODE_PIECES[chr] }.join(' ')
      end.join("\n")
    end

    def dup
      PGN::Board.new(self.squares.map(&:dup))
    end

  end
end
