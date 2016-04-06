defmodule TwitchSniper do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, client} = ExIrc.start_client!

   children = [
     # Define workers and child supervisors to be supervised

   ]

    children = [
      # Start the endpoint when the application starts
      supervisor(TwitchSniper.Endpoint, []),
      supervisor(TwitchSniper.ChatSupervisor,[]),
      # Start the Ecto repository
      supervisor(TwitchSniper.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(TwitchSniper.Worker, [arg1, arg2, arg3]),
      worker(TwitchSniper.Bot, [client])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwitchSniper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitchSniper.Endpoint.config_change(changed, removed)
    :ok
  end
end
