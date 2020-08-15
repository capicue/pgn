require 'spec_helper'

describe PGN::Game do
  describe '#positions' do
    it 'does not raise an error' do
      tags   = { 'White' => 'Deep Blue', 'Black' => 'Kasparov' }
      moves  = %w[e4 c5 c3 d5 exd5 Qxd5 d4 Nf6 Nf3 Bg4 Be2 e6 h3 Bh5 O-O Nc6 Be3 cxd4 cxd4 Bb4 a3 Ba5 Nc3 Qd6 Nb5 Qe7 Ne5 Bxe2 Qxe2 O-O Rac1 Rac8 Bg5 Bb6 Bxf6 gxf6 Nc4 Rfd8 Nxb6 axb6 Rfd1 f5 Qe3 Qf6 d5 Rxd5 Rxd5 exd5 b3 Kh8 Qxb6 Rg8 Qc5 d4 Nd6 f4 Nxb7 Ne5 Qd5 f3 g3 Nd3 Rc7 Re8 Nd6 Re1+ Kh2 Nxf2 Nxf7+ Kg7 Ng5+ Kh6 Rxh7+]
      result = '1-0'
      game = PGN::Game.new(moves, tags, result)
      expect { game.positions }.not_to raise_error
    end

    it 'has fullmove 2 after 1.e4 c5' do
      moves = %w[e4 c5]
      game = PGN::Game.new(moves)
      last_pos = game.positions.last

      expect(last_pos.fullmove).to eq 2
    end
  end
end
