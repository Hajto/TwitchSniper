defmodule TwitchSniper.VoteCommandTest do
  use ExUnit.Case

  @user "tester"

  alias TwitchSniper.Vote

  test "Sample voting" do
    Vote.start_vote(["opt 1", "opt 2"], 1000)
    TwitchSniper.Bot.process_command("!vote opt1", @user)
    assert Vote.get_results().votes["opt1"][:value] == 1

    :timer.sleep(1200)
    refute Vote.get_results.active
  end

end
