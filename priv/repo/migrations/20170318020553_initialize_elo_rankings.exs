defmodule Pong.Repo.Migrations.InitializeEloRankings do
  use Ecto.Migration

  def up do
    Pong.Match
    |> Pong.Repo.all
    |> Enum.each(fn(match) ->
      Pong.Elo.update_ranks(match)
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
