require 'spec_helper'

describe PGN::Position do
  context "disambiguating moves" do
    describe "using SAN square disambiguation" do
      pos = PGN::Position.new("r1bqkb1r/pp1p1ppp/2n1pn2/8/3NP3/2N5/PPP2PPP/R1BQKB1R w KQkq - 3 6")
      next_pos = pos.move("Ndb5")

      it "should move the specified piece" do
        next_pos.squares[3][3].should be_nil
      end

      it "should not move the other piece" do
        next_pos.squares[2][2].should == "N"
      end
    end

    describe "using discovered check" do
      pos = PGN::Position.new("rnbqk2r/p1pp1ppp/1p2pn2/8/1bPP4/2N1P3/PP3PPP/R1BQKBNR w KQkq - 0 5")
      next_pos = pos.move("Ne2")

      it "should move the piece that doesn't give discovered check" do
        next_pos.squares[6][0].should be_nil
      end

      it "shouldn't move the other piece" do
        next_pos.squares[2][2].should == "N"
      end
    end

    describe "with two pawns on the same file" do
      pos = PGN::Position.new("r2q1rk1/4bppp/p3n3/1p2n3/4N3/1B2BP2/PP3P1P/R2Q1RK1 w - - 4 19")
      next_pos = pos.move("f4")

      it "should move the pawn in front" do
        next_pos.squares[5][2].should be_nil
      end

      it "should not move the other pawn" do
        next_pos.squares[5][1].should == "P"
      end
    end
  end
end
