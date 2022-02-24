# frozen_string_literal: true

require 'io/console'
require_relative './move_text'

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

    # define methods for each official tag (seven tag roster, optional tags)
    # any additional tag, if given, can be fetched from `tags`
    #
    # `result` is already fetched from parser
    # `fen` must be given or starting FEN
    #
    PGN::TAGS.reject { |e| %i[result fen].include? e }.each do |name, tag|
      # define quick method to access tag
      define_method name do
        tags[tag]
      end
    end

    #
    # FEN either given in tags, or generates from the starting position
    #
    # @return [String] FEN string
    #
    def fen
      (tags['FEN'].nil? || tags['FEN'].empty?) ? starting_position.to_fen : tags['FEN']
    end

    #
    # movetext: notation string part in PGN format (PGN sans tags)
    #
    # @return [String] 1. ... ... 2. ... ...
    #
    def movetext
      notations # array of string notations
        .each_slice(2).to_a # grouped in pairs
        .each_with_index.map { |e, i| "#{i + 1}. #{e.join(' ')} " } # as string like "1. g4+ Kxg4"
        .join # "1. g4+ Kxg4 2. Rxa2 ..." and so on
        .strip # no extra space around
    end

    #
    # moves notations
    #
    # @return [String:Array] ["g4+", "Kxg4", "Rxa2", ...]
    #
    def notations
      moves.map(&:notation)
    end

    #
    # full PGN with headers, steps and result
    #
    # @return [String] full PGN format
    #
    def to_pgn
      [
        tags.map { |tag, value| "[#{tag} \"#{value.tr('"', "'")}\"]" }.join("\n"),
        "#{movetext} #{result || '*'}"
      ].join("\n")
    end

    # to ruby hash
    #
    def to_h
      {
        'pgn'        => to_pgn,
        'tags'       => tags,
        'movetext'   => movetext,
        'result'     => result,
        'moves'      => notations,
        'fens'       => fen_list[1..-1],
        'moves_fens' => notations.zip(fen_list[1..-1])
      }
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
      fen = (tags && tags['FEN'].to_s.strip != '' && tags['FEN'])
      @starting_position ||= (fen ? PGN::FEN.new(fen).to_position : PGN::Position.start)
    end

    # @return [Array<PGN::Position>] list of the {PGN::Position}s in the game
    #
    def positions
      @positions ||= begin
        position = starting_position
        arr      = [position]
        moves.each do |move|
          new_pos  = position.move(move.notation)
          arr     << new_pos
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
