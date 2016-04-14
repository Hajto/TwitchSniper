defmodule TwitchSniper.UserCommand do
  use TwitchSniper.Web, :model

  @param_capture "(\"[^\"]+\"\\s?)"

  schema "commands" do
    field :command, :string
    field :info, :string
    field :delay, :integer
    field :params, :integer

    timestamps
  end

  @required_fields ~w(command info delay)
  @optional_fields ~w(params)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  @doc """
  Generates regex based on command struct.
  """

  def construct_regex(model) do
    Regex.compile(model.command<>" "<>String.duplicate(@param_capture, model.params))
  end
end
