module PGN
  class Move
    attr_accessor :san
    attr_accessor :piece, :destination, :promotion, :check, :capture, :disambiguation, :castle

    # A regular expression for matching moves in standard algebraic
    # notation
    SAN_REGEX = %r{
      (?<piece>          [BKNQR]      ){0}
      (?<destination>    [a-h][1-8]   ){0}
      (?<promotion>      =[BNQR]      ){0}
      (?<check>          [#+]         ){0}
      (?<capture>        x            ){0}
      (?<disambiguation> [a-h]?[1-8]? ){0}

      (?<castle>         O-O(-O)?     ){0}

      (?<normal>
        \g<piece>?
        \g<disambiguation>
        \g<capture>?
        \g<destination>
        \g<promotion>?
      ){0}

      \A (\g<castle> | \g<normal>) \g<check>? \z
    }x

    # Extracts information from a move string
    #
    # @param move [String] the move in standard algebraic notation
    def initialize(move)
      self.san = move

      match = move.match(SAN_REGEX)

      match.names.each do |name|
        if self.respond_to?(name)
          self.send("#{name}=", match[name])
        end
      end
    end

    def piece=(val)
      @piece = val || "P"
    end

    def promotion=(val)
      @promotion = val.delete("=") if val
    end

    def capture=(val)
      @capture = !!val
    end

    def disambiguation=(val)
      @disambiguation = (val == "" ? nil : val)
    end

    def castle=(val)
      @castle = "K" if val == "O-O"
      @castle = "Q" if val == "O-O-O"
    end

    def check?
      self.check == "+"
    end

    def checkmate?
      self.check == "#"
    end

  end
end
