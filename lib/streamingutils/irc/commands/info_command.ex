defmodule TwitchSniper.InfoCommand do
  use TwitchSniper.ChatCommand
  use GenServer

  @max_commands_default 32

  @doc """
    This module handles user generated commands which are cached via GenServer on the startup.
  """

  defmodule State do
    defstruct scheduled: [],
              loaded_commands: [],
              max_commands: 0
  end

  def check(_msg, _user) do
    # GenServer.call(__MODULE__, { :check, msg, user })
    false
  end

  ## Client Api

  def update_commands do
    GenServer.cast(__MODULE__,  :reload_commands  )
  end

  ## Server Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, %State{ max_commands: get_max_commands }, name: __MODULE__)
  end

  def handle_call({:check, msg, user}, _from, state) do
    loaded_commands = state.loaded_commands
    Enum.any?(loaded_commands, fn record ->
      case perform_match(record.command, msg, user) do
        :ok -> true
        :error -> false
      end
    end)
  end

  def handle_cast(:reload_commands, state) do
    loaded_commands = TwitchSniper.Repo.all(%TwitchSniper.UserCommand{})
    { :noreply, %{ state | loaded_commands: loaded_commands } }
  end

  def get_max_commands do
    case Application.fetch_env(:streamingutils, :max_info_commands) do
      {:ok, value} -> value
      :error -> @max_commands_default
    end
  end

  def perform_match(_command, _msg, _user) do

     :error
  end

end
