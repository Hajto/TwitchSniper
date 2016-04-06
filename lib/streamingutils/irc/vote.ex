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
    Agent.get_and_update(__MODULE__, fn current_state ->
      case current_state do
        %Vote{ active: true } -> { { :error, "Already started" }, current_state }
        %Vote{ active: false } -> { {:ok, "Vote started succesfully"} , %{ current_state | active: true, votes: zero_votes(options) } }
      end
    end)
  end

  def vote_for(option, nickname) do
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

  defp zero_votes(options) do
    Enum.map( options , fn(option) -> { option, 0 } end) |> Enum.into(%{})
  end

  def end_vote do
    Agent.get_and_update(__MODULE__,  fn current_state ->
      { current_state.votes , %{ current_state | active: false, votes: Map.new } }
    end)
  end

end
