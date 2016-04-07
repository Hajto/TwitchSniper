defmodule TwitchSniper.Vote do

  alias TwitchSniper.Vote

  defstruct active: false,
            votes: Map.new(),
            voters: []

  def start_link do
    Agent.start_link(fn -> %Vote{} end, name: __MODULE__)
  end


  @doc """
    Starts new voting if possible, only one can be active at a time.

    Takes list of options as an option.
  """
  @spec start_vote(list) :: { :ok | :error, String.t }
  def start_vote(options) do
    as_string = List.to_string(options)
    TwitchSniper.Bot.send_message("Poll started, please vote using !vote command followed by option #{ as_string }")
    Agent.get_and_update(__MODULE__, fn current_state ->
      case current_state do
        %Vote{ active: true } -> { { :error, "Already started" }, current_state }
        %Vote{ active: false } -> { {:ok, "Vote started succesfully"} , %{ current_state | active: true, votes: zero_votes(options) } }
      end
    end)
  end

  def vote_for(option, nickname) do
    option = escape_string(option)
    Agent.update(__MODULE__, fn state ->
      votes = state.votes
      case Map.get(votes, option) do
        nil -> state
        current_value ->
          cond do
            nickname in state.voters ->
              state
            true ->
              updated = Map.put(votes, option, current_value + 1)
              %{ state | votes: updated, voters: state.voters ++ [nickname] }
          end
      end
    end)
  end

  def get_results do
    Agent.get(__MODULE__, fn state -> state.votes end)
  end
  
  def end_vote do
    Agent.get_and_update(__MODULE__,  fn current_state ->
      { current_state.votes , %{ current_state | active: false, votes: Map.new } }
    end)
  end

  defp zero_votes(options) do
    Enum.map(options, &(escape_string(&1)) )
    |> Enum.map(fn(option) -> { option, 0 } end) |> Enum.into(%{})
  end


  defp escape_string(text) do
    Regex.replace(~r/\s/, text,"")
    |> String.downcase
  end

end
