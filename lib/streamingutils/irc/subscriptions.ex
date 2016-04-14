defmodule TwitchSniper.Subscriptions do

  @moduledoc """
    Provides functions to parse TwitchNotify messages.
  """

  def process(msg) do
    case new_sub?(msg) do
      :nope -> is_resub?(msg)
      smth -> smth
    end
  end

  @doc """
    Checks whether given message is notification about new subscriber.
    Correct message should have format like:
    UserName just subscribed!
  """
  @spec new_sub?(String.t) :: { :ok , String.t } | :nope

  def new_sub?(msg) do
    case Regex.run(~r/(.+) just subscribed!/, msg) do
      [ _head, name ] -> { :ok, name }
      nil -> :nope
    end
  end

  @doc """
    Same as new_sub? but in this case it looks for notification about resub.
    Correct format is:
    Userame subscribed for number months in a row!
  """
  @spec is_resub?(String.t) :: { :ok , String.t } | :nope

  def is_resub?(msg) do
    case Regex.run(~r/(.+) subscribed for (\d+) months in a row!/, msg) do
      [ _a, user, how_long ]  -> { :ok, { user, how_long} }
      nil -> :nope
    end
  end

end
