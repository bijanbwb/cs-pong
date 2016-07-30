defmodule Pong.PlayerView do
  use Pong.Web, :view

  alias Pong.Match
  alias Pong.MatchView
  alias Pong.Player
  alias Pong.Repo

  @doc """
  Total number of wins for the player.
  """
  @spec wins(Player) :: integer
  def wins(%Player{id: id}) do
    player = Repo.get(Player, id)
    matches = Repo.all(Match)
    matches_won = Enum.filter(matches, fn(m) -> player.id == MatchView.player_win_id(m) end)
    Enum.count(matches_won)
  end

  @doc """
  Total number of losses for the player.
  """
  @spec losses(Player) :: integer
  def losses(%Player{id: id}) do
    player = Repo.get(Player, id)
    matches = Repo.all(Match)
    matches_lost = Enum.filter(matches, fn(m) -> player.id == MatchView.player_loss_id(m) end)
    Enum.count(matches_lost)
  end
end
