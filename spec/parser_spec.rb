require 'spec_helper'

describe PGN do
  describe '.parse' do
    it 'should return a list of games' do
      games = PGN.parse(File.read('./examples/immortal_game.pgn'))
      games.length.should == 1
      game = games.first
      game.result.should == '1-0'
      game.tags['White'].should == 'Adolf Anderssen'
      game.moves.last.should == 'Be7#'
    end

    it 'should handle alternate castling notation' do
      games = PGN.parse(File.read('./spec/pgn_files/alternate_castling.pgn'))
      game = games.first
      game.tags['White'].should == 'Somebody'
      game.result.should == '*'
      game.moves.last.should == 'O-O-O'
    end

    it 'should handle annotations' do
      games = PGN.parse(File.read('./spec/pgn_files/annotations.pgn'))
      games.each do |game|
        game.tags['White'].should == 'Fool'
        game.result.should == '0-1'
        game.moves.last.should == 'Qh4#'
      end
    end

    it 'should handle many games in order' do
      games = PGN.parse(File.read('./spec/pgn_files/two_games.pgn'))
      games.first.moves(&:notation).should == ['f3', 'e5', 'g4', 'Qh4#']
    end

    it 'should handle comments' do
      games = PGN.parse(File.read('./spec/pgn_files/comments.pgn'))
      game = games.first
      game.tags['White'].should == 'Scholar'
      game.result.should == '1-0'
      game.moves.last.should == 'Qxf7#'
    end

    it 'should handle multiline comments' do
      games = PGN.parse(File.read('./spec/pgn_files/multiline_comments.pgn'))
      game = games.first
      game.tags['White'].should == 'Scholar'
      game.result.should == '1-0'
      game.moves.last.should == 'Qxf7#'
    end

    it 'should handle nested comments' do
      games = PGN.parse(File.read('./spec/pgn_files/nested_comments.pgn'))
      game = games.first
      game.result.should == '*'
      game.moves.last.should == 'Nf6'
    end


    it 'returns empty array when no variations' do
      games = PGN.parse(File.read('./spec/pgn_files/variations.pgn'))
      game = games.first
      game.moves.first.variations.should == []
    end

    it 'should handle variations' do
      games = PGN.parse(File.read('./spec/pgn_files/variations.pgn'))
      game = games.first
      game.tags['Black'].should == 'Petrov'
      game.result.should == '*'
      game.moves.last.should == 'Nf6'
    end

    it 'should handle variations longer than 1' do
      games = PGN.parse(File.read('./spec/pgn_files/variations.pgn'))
      game = games.first
      # puts game.moves.map{|x| x.variations.to_a.count }
      game.moves[-2].variations.first.should == ['f4', 'exf4']
    end

    it 'should handle empty variation moves' do
      games = PGN.parse(File.read('./spec/pgn_files/empty_variation_move.pgn'))
      game = games.first
      game.result.should == '*'
      game.moves.last.should == 'Ng5'
    end

    it 'should handle complex files' do
      games = PGN.parse(File.read('./spec/pgn_files/test.pgn'))
      game = games.first
      game.tags['Black'].should == 'Gelfand, Boris'
      game.result.should == '1-0'
      game.moves[13].should == 'Nfd7'
      game.moves[34].should == 'f3'
      game.moves[35].annotation.should == '$6'
      game.moves[35].comment.should == "{Gelfand\ndecide tomar medidas.}"
      game.moves[35].variations.size.should == 1
      variation = game.moves[35].variations[0]
      variation.size.should == 2
      variation[0].should == 'exf3'
    end


    it 'should handle files with starting position' do
      games = PGN.parse(File.read('./spec/pgn_files/fen.pgn'))
      game = games.first
      first_pos = game.positions.first
      last_pos = game.positions.last 
      first_pos.to_fen.to_s.should == game.tags['FEN']
      last_pos.to_fen.to_s.should == '5rkn/5p1p/2b2NpP/8/2B5/1P6/2PP3P/1K6 b - - 0 4'
    end
  end
end
