defmodule TwitchSniper.PageController do
  use TwitchSniper.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
