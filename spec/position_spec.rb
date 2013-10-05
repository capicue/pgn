require 'spec_helper'

describe PGN::Position do
  context "from the start position" do
    describe "moving 1.e4" do
      it "should output the correct FEN" do
        start_pos = PGN::Position.start
        next_pos  = start_pos.move("e4")
        start_pos.fen.to_s.should == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        next_pos.fen.to_s.should == "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
      end
    end
  end
end
