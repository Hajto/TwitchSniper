defmodule TwitchSniper.VoteCommand do
  use TwitchSniper.ChatCommand

  def check(msg, user) do
    case Regex.run(~r/!vote (.+)/i,msg) do
      nil -> false
      [_head | [ option | _ ]] ->
        IO.inspect "Glosowanie "
        IO.inspect option
        TwitchSniper.Vote.vote_for(option, user)
        true
    end
  end
end
