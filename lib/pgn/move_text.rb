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
end
