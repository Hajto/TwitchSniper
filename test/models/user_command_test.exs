defmodule TwitchSniper.UserCommandTest do
  use TwitchSniper.ModelCase

  alias TwitchSniper.UserCommand

  @valid_attrs %{command: "some content", delay: 42, info: "some content", params: 3}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserCommand.changeset(%UserCommand{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserCommand.changeset(%UserCommand{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "correct regex is being generated" do
    changeset = %{ %UserCommand{} | command: "!com", params: 2 }
    {:ok, regex } = UserCommand.construct_regex(changeset)
    assert ~r/!com ("[^"]+"\s?)("[^"]+"\s?)/ == regex
    query = "!com \"opt1\" \"inny option\""
    result = Regex.run( regex , query)
    assert result == ["!com \"opt1\" \"inny option\"", "\"opt1\" ", "\"inny option\""]
  end

end
