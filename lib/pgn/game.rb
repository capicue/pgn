# frozen_string_literal: true

require 'io/console'

module PGN
  class MoveText
    attr_accessor :notation, :annotation, :comment, :variations

    def initialize(notation, annotation = nil, comment = nil, variations = nil)
      @annotation = annotation
      @comment = comment
      @notation = notation
      @variations = variations
    end

    def ==(other)
      to_s == other.to_s
    end

    def eql?(other)
      self == other
    end

    def hash
      @notation.hash
    end

    def to_s
      @notation
    end
  end

  # {PGN::Game} holds all of the information about a game. It is either
  # the result of parsing a PGN file, or created by hand.
  #
  # A {PGN::Game} has an interactive {#play} method, and can also return
  # a list of positions in {PGN::Position} format or FEN.
  #
  # @!attribute tags
  #   @return [Hash<String, String>] metadata about the game
  #   @example
  #     game.tags #=> {"White" => "Kasparov", "Black" => "Deep Blue"}
  #
  # @!attribute moves
  #   @return [Array<String>] a list of the moves in standard algebraic
  #     notation
  #   @example
  #     game.moves #=> ["e4", "c5", "Nf3", "d6", "d4", "cxd4"]
  #
  # @!attribute result
  #   @return [String] the outcome of the game
  #   @example
  #     game.result #=> "1-0"
  #
  class Game
    attr_accessor :tags, :moves, :result

    LEFT  = /(a|\x1B\[D)\z/
    RIGHT = /(d|\x1B\[C)\z/
    EXIT  = /(q|\x03)\z/

    # @param moves [Array<String>] a list of moves in SAN
    # @param tags [Hash<String, String>] metadata about the game
    # @param result [String] the outcome of the game
    #
    def initialize(moves, tags = nil, result = nil)
      self.moves  = moves
      self.tags   = tags
      self.result = result
    end

    # @param moves [Array<String>] a list of moves in SAN
    #
    # Standardize castling moves to use O's instead of 0's
    #
    def moves=(moves)
      @moves = moves.map do |m|
        if m.is_a? String
          MoveText.new(m.tr('0', 'O'))
        else
          MoveText.new(m.notation.tr('0', 'O'), m.annotation, m.comment, m.variations)
        end
      end
    end

    def starting_position
      fen = (tags && tags['FEN'])
      @starting_position ||= (fen ? PGN::FEN.new(fen).to_position : PGN::Position.start)
    end

    # @return [Array<PGN::Position>] list of the {PGN::Position}s in the game
    #
    def positions
      @positions ||= begin
        position = starting_position
        arr = [position]
        moves.each do |move|
          new_pos = position.move(move.notation)
          arr << new_pos
          position = new_pos
        end
        arr
      end
    end

    # @return [Array<String>] list of the fen representations of the positions
    #
    def fen_list
      positions.map(&:to_fen).map(&:inspect)
    end

    # Interactively step through the game
    #
    # Use +d+ to move forward, +a+ to move backward, and +^C+ to exit.
    #
    def play
      index = 0
      hist = Array.new(3, '')

      loop do
        puts "\e[H\e[2J"
        puts positions[index].inspect
        hist[0..2] = (hist[1..2] << STDIN.getch)

        case hist.join
        when LEFT
          index -= 1 if index > 0
        when RIGHT
          index += 1 if index < moves.length
        when EXIT
          break
        end
      end
    end
  end
end
