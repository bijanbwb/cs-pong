defmodule Pong.PlayerView do
  use Pong.Web, :view

  alias Pong.Match
  alias Pong.MatchView
  alias Pong.Player
  alias Pong.Repo

  @doc """
  Total number of games played for the player.
  """
  @spec total_matches(Player) :: integer
  def total_matches(%Player{id: id}) do
    player = Repo.get(Player, id)
    wins(player) + losses(player)
  end

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

  @doc """
  Win-loss percentage as a string value.
  """
  @spec win_loss_percentage(Player) :: string
  def win_loss_percentage(%Player{id: id}) do
    player = Repo.get(Player, id)
    if total_matches(player) > 0 do
      Float.to_string(wins(player) / total_matches(player) * 100, decimals: 0) <> "%"
    else
      "0%"
    end
  end

  @doc """
  All-time total number of points scored.

  The complexity of this makes me wonder if I made a grievous error somewhere in
  the planning of this application.
  """
  @spec total_points_scored(Player) :: integer
  def total_points_scored(%Player{id: id}) do
    player = Repo.get(Player, id)
    matches = Repo.all(Match)
    matches_participated_a = Enum.filter(matches, fn(m) -> player.id == m.player_a_id end)
    matches_participated_b = Enum.filter(matches, fn(m) -> player.id == m.player_b_id end)
    matches_points_scored_a = Enum.reduce(matches_participated_a, 0, fn(m, acc) -> m.player_a_points + acc end)
    matches_points_scored_b = Enum.reduce(matches_participated_b, 0, fn(m, acc) -> m.player_b_points + acc end)
    matches_points_scored_a + matches_points_scored_b
  end

  @doc """
  All-time total number of points scored against.

  The complexity of this makes me wonder if I made a grievous error somewhere in
  the planning of this application.
  """
  @spec total_points_against(Player) :: integer
  def total_points_against(%Player{id: id}) do
    player = Repo.get(Player, id)
    matches = Repo.all(Match)
    matches_participated_a = Enum.filter(matches, fn(m) -> player.id == m.player_a_id end)
    matches_participated_b = Enum.filter(matches, fn(m) -> player.id == m.player_b_id end)
    matches_points_against_a = Enum.reduce(matches_participated_a, 0, fn(m, acc) -> m.player_b_points + acc end)
    matches_points_against_b = Enum.reduce(matches_participated_b, 0, fn(m, acc) -> m.player_a_points + acc end)
    matches_points_against_a + matches_points_against_b
  end

  @doc """
  All-time total point differential. This number could potentially be positive
  or negative.
  """
  @spec total_points_differential(Player) :: string
  def total_points_differential(%Player{id: id}) do
    player = Repo.get(Player, id)
    differential = total_points_scored(player) - total_points_against(player)
    if differential > 0 do
      "+" <> Integer.to_string(differential)
    else
      differential
    end
  end

  @doc """
  Player avatar from user-entered URL. Or default avatar if one has not been
  entered yet.
  """
  @spec avatar(Player) :: string
  def avatar(%Player{id: id}) do
    player = Repo.get(Player, id)
    if player.avatar_url do
      player.avatar_url
    else
      "/images/default_avatar.png"
    end
  end
end
