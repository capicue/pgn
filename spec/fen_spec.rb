require "spec_helper"

describe PGN::FEN do
  describe "castling availability" do
    it "should remove all castling availabilitiy after castling" do
      pos = PGN::FEN.new("rnbqk2r/1p3pbp/p2p1np1/2pP4/P3PB2/2N2N2/1P3PPP/R2QKB1R b KQkq e3 0 8").to_position
      next_pos = pos.move("O-O")
      next_pos.to_fen.castling.should_not match(/k|q/)
    end

    it "should remove all castling availability after moving a king" do
      pos = PGN::FEN.new("r1b1kb1r/pp2pppp/2n5/4P3/1nB5/P4N2/1P3PPP/RNBqK2R w KQkq - 0 9").to_position
      next_pos = pos.move("Kxd1")
      next_pos.to_fen.castling.should_not match(/K|Q/)
    end

    it "should remove only the one castling option after moving a rook" do
      pos = PGN::FEN.new("r3k2r/1pp2pp1/p1pb1qn1/4p3/3PP1p1/8/PPPN1PPN/R1BQR1K1 b kq - 1 11").to_position
      next_pos = pos.move("Rxh2")
      next_pos.to_fen.castling.should_not match(/k/)
      next_pos.to_fen.castling.should match(/q/)
    end

    it "should change to a hyphen once no side can castle" do
      pos = PGN::FEN.new("r1bq1rk1/pp1nbppp/3ppn2/8/2PP1N2/P1N5/1P2BPPP/R1BQK2R w KQ - 2 9").to_position
      pos.to_fen.castling.should_not == "-"
      next_pos = pos.move("O-O")
      next_pos.to_fen.castling.should == "-"
    end
  end

  describe "en passant" do
    it "should display the en passant square whenever a pawn moves two spaces" do
      pos = PGN::FEN.new("rnbqkb1r/pppppppp/5n2/8/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 2 1").to_position
      next_pos = pos.move("c4")
      next_pos.to_fen.en_passant.should == "c3"
    end

    it "should be a hyphen if no pawn moved two spaces the previous move" do
      pos = PGN::FEN.new("rnbqkb1r/pppppppp/5n2/8/2P5/5N2/PP1PPPPP/RNBQKB1R b KQkq c3 0 1").to_position
      next_pos = pos.move("d6")
      next_pos.to_fen.en_passant.should == "-"
    end
  end

  describe "halfmove counter" do
    it "should reset after a pawn advance" do
      pos = PGN::FEN.new("2b2rk1/2pp1ppp/1p6/r3P2q/3Q4/2P5/PP3PPP/RN3RK1 w - - 3 15").to_position
      pos.to_fen.halfmove.should == "3"
      next_pos = pos.move("f4")
      next_pos.to_fen.halfmove.should == "0"
    end

    it "should reset after a capture" do
      pos = PGN::FEN.new("2r2rk1/1p2ppbp/1q1p1np1/pN4B1/Pnb1PP2/2N5/1PP1B1PP/R2Q1R1K w - - 5 14").to_position
      pos.to_fen.halfmove.should == "5"
      next_pos = pos.move("Bxc4")
      next_pos.to_fen.halfmove.should == "0"
    end

    it "should not reset otherwise" do
      pos = PGN::FEN.new("2k2b1r/p4p1p/q1p2p2/8/2br4/5P2/PPQB2PP/R1N1K2R w KQ - 0 17").to_position
      pos.to_fen.halfmove.should == "0"
      moves = %w{Qf5+ Rd7 Bc3 Bh6 Qa5 Re8+ Kf2 Be3+ Kg3 Rg8+ Kh4}
      moves.each_with_index do |move, i|
        pos = pos.move(move)
        pos.to_fen.halfmove.should == (i+1).to_s
      end
    end
  end

  describe "fullmove counter" do
    it "should not increase after white moves" do
      pos = PGN::FEN.new("4br1k/ppqnr1b1/3p3p/P1pP1p2/2P1pB2/6PP/1P2BP1N/R2QR1K1 w - - 3 25").to_position
      pos.to_fen.fullmove.should == "25"
      next_pos = pos.move("Qd2")
      next_pos.to_fen.fullmove.should == "25"
    end

    it "should increase after black moves" do
      pos = PGN::FEN.new("4br1k/ppqnr1b1/3p3p/P1pP1p2/2P1pB2/6PP/1P1QBP1N/R3R1K1 b - - 4 25").to_position
      pos.to_fen.fullmove.should == "25"
      next_pos = pos.move("Kh7")
      next_pos.to_fen.fullmove.should == "26"
    end
  end

  describe "displaying FEN notation" do
    it "should return a string on inspect" do
      fen = PGN::FEN.start
      fen.inspect.should be_a(String)
    end
  end
end
