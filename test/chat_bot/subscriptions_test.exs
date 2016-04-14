defmodule TwitchSniper.SubscriptionsTest do
  use ExUnit.Case

  alias TwitchSniper.Subscriptions

  @valid_resub "Hel_Lhound subscribed for 6 months in a row!"
  @valid_sub "EctoMaster just subscribed!"
  @invalid_sub "EctoMaster just has subscribed!"

  test "Correct resubscription is being detected" do
    assert Subscriptions.is_resub?(@valid_resub) == {:ok , { "Hel_Lhound", "6" } }
  end

  test "Correct sub" do
    assert Subscriptions.new_sub?(@valid_sub) == {:ok, "EctoMaster"}
  end

  test "Incorrect is nope" do
    assert Subscriptions.new_sub?(@invalid_sub) == :nope
  end

  test "Sub is not resub" do
    assert Subscriptions.new_sub?(@valid_resub) == :nope
  end

  test "Command is being processed correctly" do
    refute Subscriptions.process(@valid_sub) == :nope
  end

end
