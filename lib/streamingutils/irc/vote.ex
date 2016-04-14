defmodule TwitchSniper.Vote do
  use GenServer
  require Logger

  alias TwitchSniper.Vote

  defstruct active: false,
            votes: Map.new(),
            voters: [],
            delay: 1000*30

  @doc """
    Starts new voting if possible, only one can be active at a time.

    Takes list of options as an option.
  """
  @spec start_vote(list) :: { :ok | :error, String.t }
  def start_vote(options, delay \\ 30000) do
    GenServer.call(__MODULE__, {:start_poll, options, delay})
  end

  def vote_for(option, nickname) do
    option = escape_string(option)
    GenServer.cast(__MODULE__, {:vote_for, option, nickname } )
  end

  @spec get_results :: TwitchSniper.Vote
  def get_results, do: GenServer.call(__MODULE__, :get_current_results)

  def end_vote, do: GenServer.cast(__MODULE__, :finalize_poll)

  defp zero_votes(options) do
    Enum.map(options, fn(option) -> { escape_string(option), %{ :name => option, :value => 0 } } end) |> Enum.into(%{})
  end

  defp escape_string(text) do
    Regex.replace(~r/\s/, text,"")
    |> String.downcase
  end

  #Server Callbacks
  def start_link do
    GenServer.start_link(__MODULE__, %Vote{}, name: __MODULE__)
  end

  def handle_call({:start_poll, options, delay }, _from ,state) do
    as_string = List.to_string(options)
    TwitchSniper.Bot.send_message("Poll started, please vote using !vote command followed by option #{ as_string }")
    Process.send_after(__MODULE__, :times_up, delay)
    case state do
      %Vote{ active: true } -> {:reply, { :error, "Already started" }, state }
      %Vote{ active: false } -> {:reply, {:ok, "Vote started succesfully"} , %{ state | delay: delay, active: true, votes:  zero_votes(options) } }
    end
  end

  def handle_call(:get_current_results, _from ,state), do: {:reply, state, state}

  def handle_cast(:finalize_poll, state) do
    winner = Enum.reduce(state.votes, %{ :name => "none", :value => 0} ,  fn ( { _ , map} ,acc) ->
      if Map.get(map, :value) >= Map.get(acc, :value)  do
        map
      else
        acc
      end
    end)
    winner_name = winner[:name]
    winner_value = winner[:value]
    message = "Poll has ended, #{winner_name} won with #{winner_value} votes"
    TwitchSniper.Bot.send_message(message)
    Logger.info message
    {:noreply, %{ state | active: false } }
  end

  def handle_cast({:vote_for, option, username}, state) do
    votes = state.votes
    case Map.get(votes, option) do
      nil -> {:noreply, state}
      current_value ->
        cond do
          username in state.voters ->
            {:noreply, state}
          true ->
            updated = Map.put(current_value, :value , current_value[:value] + 1)
            new_votes = Map.put(votes, option, updated)
            {:noreply, %{ state | votes: new_votes, voters: state.voters ++ [username] } }
        end
    end
  end

  def handle_info(:times_up, state) do
    end_vote
    {:noreply, state}
  end

end
