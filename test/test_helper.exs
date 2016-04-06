ExUnit.start

Mix.Task.run "ecto.create", ~w(-r TwitchSniper.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r TwitchSniper.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(TwitchSniper.Repo)

