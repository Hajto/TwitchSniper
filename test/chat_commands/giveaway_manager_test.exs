defmodule TwitchSniper.GiveawayManagerTest do
  use ExUnit.Case

  alias TwitchSniper.Giveaway
  alias TwitchSniper.GiveawayManager

  test "Add 2 giveaways and cycle them" do
    giveaway_one = %Giveaway{organiser: "Asshole", product: "A very pc Game", delay: 200}
    giveaway_two = %Giveaway{organiser: "Not an asshole", product: "A Console", delay: 200}

    GiveawayManager.new_giveaway(giveaway_one)
    GiveawayManager.new_giveaway(giveaway_two)

    assert GiveawayManager.get_first == giveaway_one

    GiveawayManager.start_cycling
    :timer.sleep(giveaway_one.delay + 10) 

    assert GiveawayManager.get_first == giveaway_two
  end

end
