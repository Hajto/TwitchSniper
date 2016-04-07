defmodule TwitchSniper.Giveaway do

  @doc """
    Struct describing a giveaway.
    Organiser should be String returned from TwitchAPI or Chat.
    Product is what is being given away.
    Delay is how long will giveaway last, expressed in milis.
  """

  defstruct organiser: "nickname",
            product: "Something",
            delay: 60*1000*5,
            participants: []

  def join(giveaway, new_participant) do
    if !Enum.member?(giveaway, &(&1 == &2)) do
      %{giveaway | participants: [new_participant|giveaway.participants]}
    else
      giveaway
    end
  end

  def join_subs do
    #TODO
  end

  def finalize(giveaway) do
    
  end

end
