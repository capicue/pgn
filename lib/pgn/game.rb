require 'io/console'

module PGN
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

    LEFT  = "a"
    RIGHT = "d"
    EXIT  = "\u{0003}"

    # @param moves [Array<String>] a list of moves in SAN
    # @param tags [Hash<String, String>] metadata about the game
    # @param result [String] the outcome of the game
    #
    def initialize(moves, tags = nil, result = nil)
      self.moves  = moves
      self.tags   = tags
      self.result = result
    end

    # @return [Array<PGN::Position>] list of the {PGN::Position}s in the game
    #
    def positions
      @positions ||= begin
        position = PGN::Position.start
        arr = [position]
        self.moves.each do |move|
          new_pos = position.move(move)
          arr << new_pos
          position = new_pos
        end
        arr
      end
    end

    # @return [Array<String>] list of the fen representations of the positions
    #
    def fen_list
      self.positions.map {|p| p.to_fen.inspect }
    end

    # Interactively step through the game
    #
    # Use +d+ to move forward, +a+ to move backward, and +^C+ to exit.
    #
    def play
      index = 0
      loop do
        puts "\e[H\e[2J"
        puts self.positions[index].inspect
        case STDIN.getch
        when LEFT
          index -= 1 if index > 0
        when RIGHT
          index += 1 if index < self.moves.length
        when EXIT
          break
        end
      end
    end
  end
end
