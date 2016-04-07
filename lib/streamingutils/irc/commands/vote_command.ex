defmodule TwitchSniper.VoteCommand do
  use TwitchSniper.ChatCommand

  def check(msg, user) do
    case Regex.run(~r/!vote (.+)/ix,msg) do
      nil -> false
      [_head | [ option | _ ]] ->
        TwitchSniper.Vote.vote_for(option, user)
        true
    end
  end
end
