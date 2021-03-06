defmodule TwitchSniper.Router do
  use TwitchSniper.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TwitchSniper do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/commands", TwitchSniper do
    pipe_through :browser

    resources "/", UserCommandController
  end

  scope "/bot", TwitchSniper do
    pipe_through :browser

    get "/giveaway", BotController, :new_giveaway
    post "/giveaway", BotController, :create_giveaway
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitchSniper do
  #   pipe_through :api
  # end
end
