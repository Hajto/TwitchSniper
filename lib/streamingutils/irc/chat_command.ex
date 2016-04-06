defmodule TwitchSniper.ChatCommand do
  @callback check(String.t, String.t) :: boolean

  defmacro __using__(_) do
    quote do
      @behaviour TwitchSniper.ChatCommand
    end
  end

  def init do
    Agent.start_link(fn -> find_all_using end, name: __MODULE__)
  end

  def get_all_using do
    Agent.get(__MODULE__, fn data -> data end)
  end

  def find_all_using do
    available_modules(__MODULE__)
  end

  defp available_modules(plugin_type) do
    # Ensure the current projects code path is loaded
    Mix.Task.run("loadpaths", [])
    # Fetch all .beam files
    Path.wildcard(Path.join([Mix.Project.build_path, "**/ebin/**/*.beam"]))
    # Parse the BEAM for behaviour implementations
    |> Stream.map(fn path ->
      {:ok, {mod, chunks}} = :beam_lib.chunks('#{path}', [:attributes])
      {mod, get_in(chunks, [:attributes, :behaviour])}
    end)
    # Filter out behaviours we don't care about and duplicates
    |> Stream.filter(fn {_mod, behaviours} -> is_list(behaviours) && plugin_type in behaviours end)
    |> Enum.uniq
    |> Enum.map(fn {module, _} -> module end)
  end
end
