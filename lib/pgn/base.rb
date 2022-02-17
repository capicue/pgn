# frozen_string_literal: true

#
# Base with common attributes
#
module PGN
  CODE = {
    rulers: {
      black: %w[k q],
      white: %w[K Q]
    },
    castling: {
      kingside: 'O-O',
      queenside: 'O-O-O'
    },
    check: '+',
    checkmate: '#',
    color: {
      black: 'b',
      white: 'w'
    },
    pawns: %w[P p],
    piece: {
      b: 'b', k: 'k', n: 'n', p: 'p', q: 'q', r: 'r',
      B: 'B', K: 'K', N: 'N', P: 'P', Q: 'Q', R: 'R',
    },
    players: %i[white black],
  }
end
