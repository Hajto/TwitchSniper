defmodule TwitchSniper.Bot do
    use GenServer
    require Logger

    defmodule State do
        defstruct host: "irc.chat.twitch.tv",
                  port: 6667,
                  pass: "oauth:y34yipi127tevfrr27b2c5787hlb0m",
                  nick: "twitchsniperbot",
                  user: "twitchsniperbot",
                  name: "twitchsniperbot",
                  client: nil,
                  handlers: [],
                  channel: "#hajtosek"
    end

    alias ExIrc.Client

    def start_link(_) do
        GenServer.start_link(__MODULE__, [%State{}])
    end

    def handle_info({:connected, server, port}, config) do
      Logger.debug "Connected to #{server}:#{port}"
      Logger.debug "Logging to #{server}:#{port} as #{config.nick}.."

      {:noreply, config}
    end

    def handle_info(:logged_in, config) do
      Client.join(config.client, config.channel)
      Client.msg(config.client, :privmsg, config.channel , "I am bot!")
      Client.msg(config.client, :ctcp, config.channel, "Testing my capabilities!")
      {:noreply, config}
    end

    def handle_info({:received, msg, user , channel },config) do
      # Logger.info "Napisalem na czacie #{msg}"
      # Client.msg(config.client, :privmsg, config.channel, "Hajtosek napisa na czacie: #{msg}")
      process_command(msg, user)
      {:noreply, config}
    end

    def handle_info(msg, config) do
      # Logger.info  inspect(msg)
      {:noreply, config}
    end

    def init([state]) do
        {:ok, client}  = ExIrc.start_client!()

        # Register the event handler with ExIrc
        ExIrc.Client.add_handler client, self

        # Connect and logon to a server, join a channel and send a simple message
        ExIrc.Client.connect!(client, state.host, state.port)
        ExIrc.Client.logon(client, state.pass, state.nick, state.user, state.name)

        IO.inspect "IRC activated"
        #Initialize CommandSystem
        TwitchSniper.ChatCommand.init

        {:ok, %{state | :client => client, :handlers => [self]}}
    end

    def terminate(_, state) do
        # Quit the channel and close the underlying client connection when the process is terminating
        ExIrc.Client.quit state.client, "Goodbye, cruel world."
        ExIrc.Client.stop! state.client
        :ok
    end

    def process_command(msg, user) do
      Enum.take_while(TwitchSniper.ChatCommand.get_all_using(), fn elem ->
        !elem.check(msg,user)
      end)
    end
end