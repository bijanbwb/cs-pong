defmodule Pong.Repo.Migrations.InitializeEloRankings do
  use Ecto.Migration

  def up do
    Pong.Match
    |> Pong.Repo.all
    |> Enum.each(fn(match) ->
      player_a = Pong.Player
      |> Pong.Repo.get!(match.player_a_id)
      
      player_b = Pong.Player
      |> Pong.Repo.get!(match.player_b_id)
        
      Pong.Elo.update_ranks(match, {player_a, player_b})
    end)
  end
  
  def down do
    Pong.Player
    |> Pong.Repo.all
    |> Enum.each(fn(player) ->
      player
      |> Pong.Player.rank_changeset(
        %{games: 0, ranking: 1000.0, provisional: true}
      )
      |> Pong.Repo.update!
    end)
  end
end
