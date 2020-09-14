require 'whittle'

module PGN
  # {PGN::Parser} uses the whittle gem to parse pgn files based on their
  # context free grammar.
  #
  class Parser < Whittle::Parser
    def lex(input)
      line   = 1
      offset = 0
      ending = input.length
      @@pgn ||= ''

      until offset == ending
        next_token(input, offset, line).tap do |token|
          if !token.nil?
            token[:offset] = offset
            line, token[:line] = token[:line], line
            yield token unless token[:discarded]
            @@pgn += token[:value]
            offset += token[:value].length
          else
            raise Whittle::UnconsumedInputError,
                  "Unmatched input #{input[offset..-1].inspect} on line #{line}"
            # offset += 1
          end
        end
      end

      yield ({ name: :$end, line: line, value: nil, offset: offset })
    end

    rule(wsp: /\s+/).skip!
    rule(
      pgn_comment: /\A% .*/x
    ).skip!

    rule('[')
    rule(']')
    rule('(')
    rule(')')

    start(:pgn_database)

    rule(:pgn_database) do |r|
      r[].as { [] }
      r[:pgn_comment, :pgn_database].as { |_title, db| db }
      r[:pgn_database, :pgn_game].as { |database, game| database << game }
    end

    rule(:pgn_game) do |r|
      r[:tag_section, :movetext_section].as do |tags, moves|
        old_pgn = @@pgn
        @@pgn = ''
        result = moves.pop
        { tags: tags, result: result[:result], moves: moves, pgn: old_pgn, comment: result[:comment] }
      end
    end

    rule(:tag_section) do |r|
      r[:tag_pair, :tag_section].as { |pair, section| section.merge(pair) }
      r[:tag_pair]
    end

    rule(:tag_pair) do |r|
      r['[', :tag_name, :tag_value, ']'].as { |_, a, b, _| { a => b } }
    end

    rule(:tag_value) do |r|
      r[:string].as { |value| value[1...-1] }
    end

    rule(:movetext_section) do |r|
      r[:element_sequence, :comment, :game_termination].as { |a, c, t| a << { result: t, comment: c } }
      r[:element_sequence, :game_termination].as { |a, b| a << { result: b } }
    end

    rule(:element_sequence) do |r|
      r[:element_sequence, :element].as do |sequence, element|
        element.nil? ? sequence : sequence << element
      end
      r[].as { [] }
    end

    rule(:element) do |r|
      r[:move_number_indication].as { nil }
      r[:san_move_annotated]
      r[:san_move_annotated, :variation_list].as do |move, variations|
        move.variations = variations
        move
      end
      r[:comment].as { nil }
    end

    rule(:san_move_annotated) do |r|
      r[:san_move].as { |move| MoveText.new(move) }
      r[:san_move, :comment].as do |move, comment|
        MoveText.new(move, nil, comment)
      end
      r[:san_move, :annotation_list].as do |move, annotation|
        MoveText.new(move, annotation)
      end
      r[:san_move, :annotation_list, :comment].as do |move, annotation, comment|
        MoveText.new(move, annotation, comment)
      end
      r[:san_move, :comment, :annotation_list].as do |move, comment, annotation|
        MoveText.new(move, annotation, comment)
      end
    end

    rule(:annotation_list) do |r|
      r[:annotation_list, :numeric_annotation_glyph].as do |sequence, element|
        element.nil? ? sequence : sequence << element
      end
      r[:numeric_annotation_glyph].as { |v| [v] }
    end

    rule(:variation_list) do |r|
      r[:variation, :variation_list].as do |variation, sequence|
        sequence << variation
      end
      r[:variation].as { |v| [v] }
    end

    rule(:variation) do |r|
      r['(', :element_sequence, ')'].as { |_, sequence, _| sequence }
    end

    rule(
      string: /
        "                          # beginning of string
        (
          [[:print:]&&[^\\"]] |    # printing characters except quote and backslash
          \\\\                |    # escaped backslashes
          \\"                      # escaped quotation marks
        )*                         # zero or more of the above
        "                          # end of string
      /x
    )

    rule(
      comment: /
        (
          \{                           # beginning of comment
          (
            [[:print:]&&[^\\\{\}]] |   # printing characters except brace and backslash
            \n                     |
            \\\\                   |   # escaped backslashes
            \\\{|\\\}              |   # escaped braces
            \n                     |   # newlines
            \g<1>                      # recursive
          )*                           # zero or more of the above
          \}                           # end of comment
        )
      /x
    )

    rule(
      game_termination: %r{
        1-0       |    # white wins
        0-1       |    # black wins
        1\/2-1\/2 |    # draw
        \*             # ?
      }x
    )

    rule(
      move_number_indication: /
        [[:digit:]]+\.*    # one or more digits followed by zero or more periods
      /x
    )

    rule(
      san_move: %r{
        (
          --                           |    # "don't care" move (used in variations)
          [O0](-[O0]){1,2}             |    # castling (O-O, O-O-O)
          [a-h][1-8]                   |    # pawn moves (e4, d7)
          [BKNQR][a-h1-8]?x?[a-h][1-8] |    # major piece moves w/ optional specifier
                                            # and capture
                                            # (Bd2, N4c3, Raxc1)
          [a-h][1-8]?x[a-h][1-8]            # pawn captures
        )
        (
          =[BNQR]                            # optional promotion (d8=Q)
        )?
        (
          \+                            |    # check (g5+)
          \#                                 # checkmate (Qe7#)
        )?
      }x
    )

    rule(
      tag_name: /
        [A-Za-z0-9_]+    # letters, digits and underscores only
      /x
    )

    rule(
      numeric_annotation_glyph: /
        \$\d+       | # dollar sign followed by an integer from 0 to 255
        [\?!][\?!]?   # support the most used annotations directly
      /x
    )
  end
end
