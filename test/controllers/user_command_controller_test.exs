defmodule TwitchSniper.UserCommandControllerTest do
  use TwitchSniper.ConnCase

  alias TwitchSniper.UserCommand
  @valid_attrs %{command: "some content", delay: 42, info: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_command_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing commands"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_command_path(conn, :new)
    assert html_response(conn, 200) =~ "New user command"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_command_path(conn, :create), user_command: @valid_attrs
    assert redirected_to(conn) == user_command_path(conn, :index)
    assert Repo.get_by(UserCommand, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_command_path(conn, :create), user_command: @invalid_attrs
    assert html_response(conn, 200) =~ "New user command"
  end

  test "shows chosen resource", %{conn: conn} do
    user_command = Repo.insert! %UserCommand{}
    conn = get conn, user_command_path(conn, :show, user_command)
    assert html_response(conn, 200) =~ "Show user command"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_command_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user_command = Repo.insert! %UserCommand{}
    conn = get conn, user_command_path(conn, :edit, user_command)
    assert html_response(conn, 200) =~ "Edit user command"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user_command = Repo.insert! %UserCommand{}
    conn = put conn, user_command_path(conn, :update, user_command), user_command: @valid_attrs
    assert redirected_to(conn) == user_command_path(conn, :show, user_command)
    assert Repo.get_by(UserCommand, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user_command = Repo.insert! %UserCommand{}
    conn = put conn, user_command_path(conn, :update, user_command), user_command: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user command"
  end

  test "deletes chosen resource", %{conn: conn} do
    user_command = Repo.insert! %UserCommand{}
    conn = delete conn, user_command_path(conn, :delete, user_command)
    assert redirected_to(conn) == user_command_path(conn, :index)
    refute Repo.get(UserCommand, user_command.id)
  end
end
