defmodule TwitchSniper.BotController do
  use TwitchSniper.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new_giveaway(conn, _params) do
    render conn, "giveaway.html"
  end

  def create_giveaway(conn, %{"giveaway" => giveaway }) do
    IO.inspect giveaway
    text conn, "Dziala"
  end
end
