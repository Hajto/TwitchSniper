defmodule TwitchSniper.Repo.Migrations.CreateUserCommand do
  use Ecto.Migration

  def change do
    create table(:commands) do
      add :command, :string
      add :info, :string
      add :delay, :integer
      add :params, :integer, default: 0

      timestamps
    end

  end
end
