require 'spec_helper'

describe PGN do
  describe '.parse' do
    it 'should return a list of games' do
      games = PGN.parse(File.read('./examples/immortal_game.pgn'))
      expect(games.length).to eq 1
      game = games.first
      expect(game.result).to eq '1-0'
      expect(game.tags['White']).to eq 'Adolf Anderssen'
      expect(game.moves.last).to eq 'Be7#'
    end

    it 'should handle alternate castling notation' do
      games = PGN.parse(File.read('./spec/pgn_files/alternate_castling.pgn'))
      game = games.first
      expect(game.tags['White']).to eq 'Somebody'
      expect(game.result).to eq  '*'
      expect(game.moves.last).to eq 'O-O-O'
    end

    it 'should handle annotations' do
      games = PGN.parse(File.read('./spec/pgn_files/annotations.pgn'))
      games.each do |game|
        expect(game.tags['White']).to eq 'Fool'
        expect(game.result).to eq  '0-1'
        expect(game.moves.last).to eq  'Qh4#'
      end
    end

    it 'should handle many games in order' do
      games = PGN.parse(File.read('./spec/pgn_files/two_games.pgn'))
      expect(games.first.moves(&:notation)).to eq ['f3', 'e5', 'g4', 'Qh4#']
    end

    it 'should handle comments' do
      games = PGN.parse(File.read('./spec/pgn_files/comments.pgn'))
      game = games.first
      expect(game.tags['White']).to eq 'Scholar'
      expect(game.result).to eq  '1-0'
      expect(game.moves.last).to eq  'Qxf7#'
    end

    it 'should handle multiline comments' do
      games = PGN.parse(File.read('./spec/pgn_files/multiline_comments.pgn'))
      game = games.first
      expect(game.tags['White']).to eq 'Scholar'
      expect(game.result).to eq  '1-0'
      expect(game.moves.last).to eq  'Qxf7#'
    end

    it 'should handle nested comments' do
      games = PGN.parse(File.read('./spec/pgn_files/nested_comments.pgn'))
      game = games.first
      expect(game.result).to eq  '*'
      expect(game.moves.last).to eq 'Nf6'
    end

    it 'handles two annotations' do
      games = PGN.parse(File.read('./spec/pgn_files/two_annotations.pgn'))
      game = games.first
      expect(game.moves[1].annotation).to eq ['$2', '$11']
    end

    it 'returns empty array when no variations' do
      games = PGN.parse(File.read('./spec/pgn_files/variations.pgn'))
      game = games.first
      expect(game.moves.first.variations).to eq []
    end

    it 'should handle variations' do
      games = PGN.parse(File.read('./spec/pgn_files/variations.pgn'))
      game = games.first
      expect(game.tags['Black']).to eq 'Petrov'
      expect(game.result).to eq  '*'
      expect(game.moves.last).to eq 'Nf6'
    end

    it 'should handle variations longer than 1' do
      games = PGN.parse(File.read('./spec/pgn_files/variations.pgn'))
      game = games.first
      # puts game.moves.map{|x| x.variations.to_a.count }
      expect(game.moves[-2].variations.first).to eq %w[f4 exf4]
    end

    it 'should handle empty variation moves' do
      games = PGN.parse(File.read('./spec/pgn_files/empty_variation_move.pgn'))
      game = games.first
      expect(game.result).to eq  '*'
      expect(game.moves.last).to eq 'Ng5'
    end

    it 'should handle complex files' do
      games = PGN.parse(File.read('./spec/pgn_files/test.pgn'))
      game = games.first
      expect(game.tags['Black']).to eq 'Gelfand, Boris'
      expect(game.result).to eq '1-0'
      expect(game.moves[13]).to eq  'Nfd7'
      expect(game.moves[34]).to eq  'f3'
      expect(game.moves[35].annotation).to eq ['$6']
      expect(game.moves[35].comment).to eq 'Gelfand decide tomar medidas.'
      expect(game.moves[35].variations.size).to eq 1
      variation = game.moves[35].variations[0]
      expect(variation.size).to eq 2
      expect(variation[0]).to eq  'exf3'
    end

    it 'should handle files with starting position' do
      games = PGN.parse(File.read('./spec/pgn_files/fen.pgn'))
      game = games.first
      first_pos = game.positions.first
      last_pos = game.positions.last
      expect(first_pos.to_fen.to_s).to eq game.tags['FEN']
      expect(last_pos.to_fen.to_s).to eq '5rkn/5p1p/2b2NpP/8/2B5/1P6/2PP3P/1K6 b - - 0 4'
    end

    it 'returns original game pgn' do
      games = PGN.parse(File.read('./spec/pgn_files/fen.pgn'))
      game = games.first
      expect(game.pgn).to eq "[Event \"Event 1\"]\n[FEN \"4brkn/4bp1p/3q2pP/8/2B3N1/1P4N1/2PP3P/1K2Q3 w - - 0 1\"]\n[PlyCount \"7\"]\n\n1. Qxe7 Qxe7 2. Ne4 Bc6 3. Nef6+ Qxf6 4. Nxf6# 1-0"
    end

    it 'returns original game pgn for second game' do
      games = PGN.parse(File.read('./spec/pgn_files/two_games.pgn'))
      game = games.last
      expect(game.pgn).to eq "[White \"Fool 2\"]\n[Black \"Somebody else 2\"]\n\n1. e4 e5 0-1\n"
    end

    it 'parses empty game' do
      games = PGN.parse(File.read('./spec/pgn_files/no_moves.pgn'))
      game = games.last
      expect { game.positions }.not_to raise_error
    end
  end
end
