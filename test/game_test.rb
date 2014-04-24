require "minitest/autorun"
require "mocha/mini_test"

require_relative "../lib/weiqi"
require_relative "helpers/game_session"

describe "Game" do
  let(:engine)     { mock("Engine") }
  let(:game)       { Weiqi::Game.new(engine, Weiqi::SequentialScheduler.new) }
  let(:session)    { GameSession.new(engine, game) }
  let(:transcript) { [] }

  it "must be able to end game end by passing" do
    assert_output "PASS!\nGame over. Final score 0\n" do
      session.black_passes
             .white_passes
             .final_score(0)
             .game_ends
    end
  end

  it "must be able to end game by resignation" do
    assert_output "PASS!\nYou win! The computer resigned\n" do
      session.black_passes
             .white_resigns
             .game_ends
    end
  end

  it "must be able to notify observers of moves" do
   moves = []
   game.observe { |board| moves << board.last_move }
   
   session.black_plays(3,3)
          .white_plays(3,4)
          .black_plays(4,4)
          .white_plays(5,5)
          .verify_results

    moves.must_equal([[3,3],[3,4],[4,4],[5,5]])
  end
end
