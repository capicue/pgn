# frozen_string_literal: true

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
      expect(game.result).to eq '*'
      expect(game.moves.last).to eq 'O-O-O'
    end

    it 'should handle annotations' do
      games = PGN.parse(File.read('./spec/pgn_files/annotations.pgn'))
      games.each do |game|
        expect(game.tags['White']).to eq 'Fool'
        expect(game.result).to eq '0-1'
        expect(game.moves.last).to eq 'Qh4#'
      end
    end

    it 'should handle comments' do
      games = PGN.parse(File.read('./spec/pgn_files/comments.pgn'))
      game = games.first
      expect(game.tags['White']).to eq 'Scholar'
      expect(game.result).to eq '1-0'
      expect(game.moves.last).to eq 'Qxf7#'
    end

    it 'should handle multiline comments' do
      games = PGN.parse(File.read('./spec/pgn_files/multiline_comments.pgn'))
      game = games.first
      expect(game.tags['White']).to eq 'Scholar'
      expect(game.result).to eq '1-0'
      expect(game.moves.last).to eq 'Qxf7#'
    end

    it 'should handle nested comments' do
      games = PGN.parse(File.read('./spec/pgn_files/nested_comments.pgn'))
      game = games.first
      expect(game.result).to eq '*'
      expect(game.moves.last).to eq 'Nf6'
    end

    it 'should handle variations' do
      games = PGN.parse(File.read('./spec/pgn_files/variations.pgn'))
      game = games.first
      expect(game.tags['Black']).to eq 'Petrov'
      expect(game.result).to eq '*'
      expect(game.moves.last).to eq 'Nf6'
    end

    it 'should handle empty variation moves' do
      games = PGN.parse(File.read('./spec/pgn_files/empty_variation_move.pgn'))
      game = games.first
      expect(game.result).to eq '*'
      expect(game.moves.last).to eq 'Ng5'
    end

    it 'should handle complex files' do
      games = PGN.parse(File.read('./spec/pgn_files/test.pgn'))
      game = games.first
      expect(game.tags['Black']).to eq 'Gelfand, Boris'
      expect(game.result).to eq '1-0'
      expect(game.moves[13]).to eq 'Nfd7'
      expect(game.moves[34]).to eq 'f3'
      expect(game.moves[35].annotation).to eq '$6'
      expect(game.moves[35].comment).to eq "{Gelfand\ndecide tomar medidas.}"
      expect(game.moves[35].variations.size).to eq 1
      variation = game.moves[35].variations[0]
      expect(variation.size).to eq 2
      expect(variation[0]).to eq 'Nxf3'
    end

    it 'should handle files with starting position' do
      games = PGN.parse(File.read('./spec/pgn_files/fen.pgn'))
      game = games.first
      first_pos = game.positions.first
      last_pos = game.positions.last
      expect(first_pos.to_fen.to_s).to eq game.tags['FEN']
      expect(last_pos.to_fen.to_s).to eq '5rkn/5p1p/2b2NpP/8/2B5/1P6/2PP3P/1K6 b - - 0 4'
    end
  end
end
