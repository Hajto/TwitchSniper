defmodule TwitchSniper.GiveawayManager do
  use GenServer
  require Logger

  @moduledoc """
  Manages current giveaways and cycles them.
  """

  alias TwitchSniper.Giveaway

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec new_giveaway(TwitchSniper.Giveaway) :: :ok
  def new_giveaway(item) do
    GenServer.cast(__MODULE__, {:new_item, item})
  end

  def get_first do
    GenServer.call(__MODULE__, {:get_first} )
  end

  def cycle do
    GenServer.cast(__MODULE__, {:cycle} )
  end

  def start_cycling do
    Process.send_after(__MODULE__, {:time_trigger} , get_first.delay)
  end

  def start_cycling(delay) do
    Process.send_after(__MODULE__, { :time_trigger }, delay)
  end

  ##ServerSide Callback
  def init(:ok) do
    {:ok, :queue.new }
  end

  def handle_call({:get_first}, _from, state) do
    if(:queue.is_empty(state)) do
      {:reply, nil, state}
    else
      {:reply, :queue.get(state) , state}
    end
  end

  def handle_cast({ :cycle }, state) do
    cond do
      :queue.is_empty(state) -> { :noreply, state }
      true ->
        { { _ , finalized }, new_queue} = :queue.out(state)
        Giveaway.finalize(finalized)
        new_item = :queue.get(new_queue)
        start_cycling(new_item.delay)
        {:noreply, new_queue }
    end
  end

  def handle_cast({:new_item, giveaway}, state) do
    {:noreply, :queue.in(giveaway, state)}
  end

  def handle_info({:time_trigger}, state)do
    cycle
    {:noreply, state}
  end

  def handle_info( message, state) do
    Logger.error message
    {:noreply, state}
  end

end
