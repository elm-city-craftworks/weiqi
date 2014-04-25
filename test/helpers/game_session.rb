class GameSession
  def initialize(mock_engine, game)
    @moves   = Mocha::Sequence.new('moves')
    @engine  = mock_engine
    @game    = game

    @actions = []
  end

  def black_passes
    @engine.expects(:pass_black).in_sequence(@moves).returns(move("PASS"))

    @actions << lambda { @game.pass }

    self
  end

  def black_plays(x,y)
    @engine.expects(:play_black).in_sequence(@moves).returns(move([x,y]))

    @actions << lambda { @game.play(x, y) }

    self
  end

  def white_plays(x,y)
    @engine.expects(:play_white).in_sequence(@moves).returns(move([x,y]))

    self
  end

  def white_passes
    @engine.expects(:play_white).in_sequence(@moves).returns(move("PASS"))

    self
  end

  def white_resigns
    @engine.expects(:play_white).in_sequence(@moves).returns(move("resign"))

    self
  end

  def final_score(num)
    @engine.expects(:final_score).returns(num)

    self
  end

  def game_ends
    @engine.expects(:quit)

    verify_results

    self
  end

  def verify_results
    @actions.each { |a| a.call }

    self
  end

  private

  def move(data)
    Struct.new(:last_move).new(data)
  end
end
