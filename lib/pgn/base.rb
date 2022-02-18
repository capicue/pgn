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

  TAGS = {
    # 
    # Seven Tag Roster
    # 
    # Name of the tournament or match event.
    event: 'Event',
    # Location of the event. This is in City, Region COUNTRY format, where
    # COUNTRY is the three-letter International Olympic Committee code for the
    # country. An example is New York City, NY USA.
    # 
    # Although not part of the specification, some online chess platforms will
    # include a URL or website as the site value.
    site: 'Site',
    # Starting date of the game, in YYYY.MM.DD form. ?? is used for unknown values.
    date: 'Date',
    # Playing round ordinal of the game within the event.
    round: 'Round',
    # Player of the white pieces, in Lastname, Firstname format.
    white: 'White',
    # Player of the black pieces, same format as White.
    black: 'Black',
    # Result of the game. It is recorded as White score, dash, then Black score, or * (other, e.g., the game is ongoing).
    result: 'Result',
    # 
    # Optional tag pairs
    # 
    # The person providing notes to the game.
    annotator: 'Annotator',
    # String value denoting the total number of half-moves played.
    ply_count: 'PlyCount',
    # e.g. 40/7200:3600 (moves per seconds: sudden death seconds)
    time_control: 'TimeControl',
    # Time the game started, in HH:MM:SS format, in local clock time.
    time: 'Time',
    # Gives more details about the termination of the game. It may be
    # abandoned, adjudication (result determined by third-party adjudication),
    # death, emergency, normal, rules infraction, time forfeit, or
    # unterminated.
    termination: 'Termination',
    # OTB (over-the-board) ICS (Internet Chess Server)
    mode: 'Mode',
    # The initial position of the chessboard, in Forsyth–Edwards Notation.
    # This is used to record partial games (starting at some initial
    # position). It is also necessary for chess variants such as Chess960,
    # where the initial position is not always the same as traditional chess.
    fen: 'FEN',
    # If a FEN tag is used, a separate tag pair SetUp must also appear and
    # have its value set to 1.
    setup: 'SetUp'
  }
end
