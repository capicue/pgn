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

    it 'should read sample one' do
      games = PGN.parse(File.read('./spec/pgn_files/sample_one.pgn'))
      game = games.first
      expect(game.black).to eq 'Player #2'
      expect(game.white).to eq 'Player #1'
      expect(game.result).to eq '0-1'
      expect(game.moves[11].to_s).to eq 'Be7'
      expect(game.moves[34].to_s).to eq 'Bg5'
      expect(game.moves[39].annotation).to eq $6
      expect(game.moves[45].variations[0][0].comment).to eq "{\nalso considered this a bit}"
      expect(game.moves[41].variations[0].length).to eq 2
      variation = game.moves[45].variations[0]
      expect(variation.size).to eq 1
      expect(variation[0].to_s).to eq 'g6'
    end

    it 'should convert game to ruby Hash' do
      games = PGN.parse(File.read('./spec/pgn_files/sample_one.pgn'))
      game = games.first
      hash = game.to_h
      expect(hash.keys).to include(*%w[pgn tags movetext result moves fens moves_fens])
      expect(hash["tags"]).to include(*%w[Event Site Date Round White Black Result])
      expect(game.black).to eq 'Player #2'
      expect(game.white).to eq 'Player #1'
      expect(game.result).to eq '0-1'
      expect(game.fen).to eq 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
      expect(hash['fens'].length).to eq 124
      expect(hash['moves'].length).to eq 124
      expect(hash['moves'].first).to eq 'e4'
      expect(hash['moves'][10]).to eq 'Bb3'
      expect(hash['fens'][0]).to eq 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1'
      expect(hash['fens'][10]).to eq 'r1bqkb1r/2pp1ppp/p1n2n2/1p2p3/4P3/1B3N2/PPPP1PPP/RNBQ1RK1 b kq - 1 6'
    end
  end
end
