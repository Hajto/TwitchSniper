defmodule TwitchSniper.UserCommandController do
  use TwitchSniper.Web, :controller

  alias TwitchSniper.UserCommand

  plug :scrub_params, "user_command" when action in [:create, :update]

  def index(conn, _params) do
    commands = Repo.all(UserCommand)
    render(conn, "index.html", commands: commands)
  end

  def new(conn, _params) do
    changeset = UserCommand.changeset(%UserCommand{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_command" => user_command_params}) do
    changeset = UserCommand.changeset(%UserCommand{}, user_command_params)

    case Repo.insert(changeset) do
      {:ok, _user_command} ->
        conn
        |> put_flash(:info, "User command created successfully.")
        |> redirect(to: user_command_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_command = Repo.get!(UserCommand, id)
    render(conn, "show.html", user_command: user_command)
  end

  def edit(conn, %{"id" => id}) do
    user_command = Repo.get!(UserCommand, id)
    changeset = UserCommand.changeset(user_command)
    render(conn, "edit.html", user_command: user_command, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user_command" => user_command_params}) do
    user_command = Repo.get!(UserCommand, id)
    changeset = UserCommand.changeset(user_command, user_command_params)

    case Repo.update(changeset) do
      {:ok, user_command} ->
        conn
        |> put_flash(:info, "User command updated successfully.")
        |> redirect(to: user_command_path(conn, :show, user_command))
      {:error, changeset} ->
        render(conn, "edit.html", user_command: user_command, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_command = Repo.get!(UserCommand, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_command)

    conn
    |> put_flash(:info, "User command deleted successfully.")
    |> redirect(to: user_command_path(conn, :index))
  end
end
