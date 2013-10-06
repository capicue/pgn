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
end
