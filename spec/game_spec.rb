# frozen_string_literal: true

require 'spec_helper'

describe PGN::Game do
  context 'attributes and methods' do
    let(:games) { PGN.parse(File.read('./spec/pgn_files/fen.pgn')) }

    it 'should have direct method for each tag' do
      PGN::TAGS.keys.each do |tag|
        expect { games.first.send(tag) }.not_to raise_error
      end
    end

    it 'should read when FEN if given' do
      expect(games.first.fen).to eq '4brkn/4bp1p/3q2pP/8/2B3N1/1P4N1/2PP3P/1K2Q3 w - - 0 1'
    end

    it 'should have a default start FEN when not available in tags' do
      games = PGN.parse(File.read('./spec/pgn_files/comments.pgn'))
      expect(games.first.fen).to eq 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
    end

    it 'should have a movetext' do
      expect(games.first.movetext).to eq '1. Qxe7 Qxe7 2. Ne4 Bc6 3. Nef6+ Qxf6 4. Nxf6#'
    end

    it 'should have an array of move notations' do
      expect(games.first.notations).to eq %w[Qxe7 Qxe7 Ne4 Bc6 Nef6+ Qxf6 Nxf6#]
    end

    it 'should generate the PGN format' do
      # read all lines of the PGN file
      lines = File.readlines('./spec/pgn_files/fen.pgn').reject(&:empty?)
      # for each line in PGN
      lines.each do |line|
        # verify that line exists in generated PGN
        expect(games.first.to_pgn).to include(line)
      end
    end

    it 'should return a hash using to_h' do
      expect(games.first.to_h.keys).to eq %w[pgn tags movetext result moves fens moves_fens]
      expect(games.first.to_h['fens']).to eq [
        "4brkn/4Qp1p/3q2pP/8/2B3N1/1P4N1/2PP3P/1K6 b - - 0 1",
        "4brkn/4qp1p/6pP/8/2B3N1/1P4N1/2PP3P/1K6 w - - 0 2",
        "4brkn/4qp1p/6pP/8/2B1N1N1/1P6/2PP3P/1K6 b - - 1 2",
        "5rkn/4qp1p/2b3pP/8/2B1N1N1/1P6/2PP3P/1K6 w - - 2 3",
        "5rkn/4qp1p/2b2NpP/8/2B3N1/1P6/2PP3P/1K6 b - - 3 3",
        "5rkn/5p1p/2b2qpP/8/2B3N1/1P6/2PP3P/1K6 w - - 0 4",
        "5rkn/5p1p/2b2NpP/8/2B5/1P6/2PP3P/1K6 b - - 0 4"
      ]
      expect(games.first.to_h['moves']).to eq ["Qxe7", "Qxe7", "Ne4", "Bc6", "Nef6+", "Qxf6", "Nxf6#"]
      expect(games.first.to_h['moves_fens'].first).to eq ["Qxe7" , "4brkn/4Qp1p/3q2pP/8/2B3N1/1P4N1/2PP3P/1K6 b - - 0 1"]
      expect(games.first.to_h['moves_fens'].last ).to eq ["Nxf6#", "5rkn/5p1p/2b2NpP/8/2B5/1P6/2PP3P/1K6 b - - 0 4"     ]
    end
  end

  describe '#positions' do
    it 'should not raise an error' do
      tags   = { 'White' => 'Deep Blue', 'Black' => 'Kasparov' }
      moves  = %w[
        e4 c5 c3 d5 exd5 Qxd5 d4 Nf6 Nf3 Bg4 Be2 e6 h3 Bh5 O-O Nc6 Be3 cxd4 cxd4
        Bb4 a3 Ba5 Nc3 Qd6 Nb5 Qe7 Ne5 Bxe2 Qxe2 O-O Rac1 Rac8 Bg5 Bb6 Bxf6 gxf6
        Nc4 Rfd8 Nxb6 axb6 Rfd1 f5 Qe3 Qf6 d5 Rxd5 Rxd5 exd5 b3 Kh8 Qxb6 Rg8 Qc5 d4
        Nd6 f4 Nxb7 Ne5 Qd5 f3 g3 Nd3 Rc7 Re8 Nd6 Re1+ Kh2 Nxf2 Nxf7+ Kg7 Ng5+ Kh6 Rxh7+
      ]
      result = '1-0'
      game = PGN::Game.new(moves, tags, result)
      expect { game.positions }.not_to raise_error
    end

    it 'should have fullmove 2 after 1.e4 c5' do
      moves = %w[e4 c5]
      game = PGN::Game.new(moves)
      last_pos = game.positions.last

      expect(last_pos.fullmove).to eq 2
    end
  end
end
