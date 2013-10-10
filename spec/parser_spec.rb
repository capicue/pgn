require 'spec_helper'

describe PGN do
  describe "parsing a file" do
    it "should return a list of games" do
      games = PGN.parse(File.read("./examples/immortal_game.pgn"))
      games.length.should == 1
      game = games.first
      game.result.should == "1-0"
      game.tags["White"].should == "Adolf Anderssen"
      game.moves.last.should == "Be7#"
    end
  end

  context "alternate castling notation" do
    describe "parsing a file" do
      it "should return a list of games" do
        games = PGN.parse(File.read("./spec/pgn_files/alternate_castling.pgn"))
        game = games.first
        game.tags["White"].should == "Somebody"
        game.result.should == "*"
        game.moves.last.should == "O-O-O"
      end
    end
  end
end
