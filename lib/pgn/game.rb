require 'io/console'

module PGN
  class MoveText
    attr_accessor :notation, :annotation, :comment, :variations
    
    def initialize(notation, annotation = nil, comment = nil, variations = [])
      @notation = notation
      @annotation = annotation
      @comment = clean_text(comment)
      @variations = variations
    end
    
    def ==(m)
      self.to_s == m.to_s
    end
    
    def eql?(m)
      self == m
    end
    
    def hash
      @notation.hash
    end
    
    def to_s
      @notation
    end

    def clean_text(text)
      text&.gsub(/{(.*)}/, '\1')&.gsub(/\s+/, ' ')&.strip
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

    LEFT  = %r{(a|\x1B\[D)\z}
    RIGHT = %r{(d|\x1B\[C)\z}
    EXIT  = %r{(q|\x03)\z}

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
          MoveText.new(m.gsub("0", "O"))
        else
          MoveText.new(m.notation.gsub("0", "O"), m.annotation, m.comment, m.variations)
        end
      end
    end

    def starting_position
      @starting_position ||= if fen = (self.tags && self.tags['FEN'])
                               PGN::FEN.new(fen).to_position
                             else 
                               PGN::Position.start 
                             end 
    end 

    # @return [Array<PGN::Position>] list of the {PGN::Position}s in the game
    #
    def positions
      @positions ||= begin
        position = starting_position
        arr = [position]
        self.moves.each do |move|
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
      self.positions.map {|p| p.to_fen.inspect }
    end

    # Interactively step through the game
    #
    # Use +d+ to move forward, +a+ to move backward, and +^C+ to exit.
    #
    def play
      index = 0
      hist = Array.new(3, "")

      loop do
        puts "\e[H\e[2J"
        puts self.positions[index].inspect
        hist[0..2] = (hist[1..2] << STDIN.getch)

        case hist.join
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
