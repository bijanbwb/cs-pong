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
  List of recent matches that the player has participated in.
  """
  @spec recent_matches(Player) :: List
  def recent_matches(%Player{id: id}) do
    player = Repo.get(Player, id)
    matches = Repo.all(Match)
    player_matches = Enum.filter(matches, fn(m) -> player.id == m.player_a_id || player.id == m.player_b_id end)
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
  @spec win_loss_percentage(Player) :: String
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
  @spec total_points_differential(Player) :: String
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
  @spec avatar(Player) :: String
  def avatar(%Player{id: id}) do
    player = Repo.get(Player, id)
    if player.avatar_url do
      player.avatar_url
    else
      "/images/default_avatar.png"
    end
  end

  @doc """
  Win-loss percentage for the player with the highest all-time value.
  """
  @spec highest_win_percentage :: string
  def highest_win_percentage do
    players = Repo.all(Player)
    if Enum.count(players) > 0 do
      highest_winning_player = Enum.max_by(players, fn(p) -> win_loss_percentage(p) end)
      win_loss_percentage(highest_winning_player)
    end
  end

  @doc """
  Name of the player with the highest all-time win percentage.
  """
  @spec highest_win_percentage_name :: string
  def highest_win_percentage_name do
    players = Repo.all(Player)
    if Enum.count(players) > 0 do
      highest_winning_player = Enum.max_by(players, fn(p) -> win_loss_percentage(p) end)
      highest_winning_player.name
    end
  end

  @doc """
  Number of wins for the player with the most all-time wins.
  """
  @spec most_wins :: string
  def most_wins do
    players = Repo.all(Player)
    if Enum.count(players) > 0 do
      winningest_player = Enum.max_by(players, fn(p) -> wins(p) end)
      wins(winningest_player)
    end
  end

  @doc """
  Name of the player with the most all-time wins.
  """
  @spec most_wins_name :: string
  def most_wins_name do
    players = Repo.all(Player)
    if Enum.count(players) > 0 do
      winningest_player = Enum.max_by(players, fn(p) -> wins(p) end)
      winningest_player.name
    end
  end

  @doc """
  Total points for the player with the most all-time points.
  """
  @spec most_points :: string
  def most_points do
    players = Repo.all(Player)
    if Enum.count(players) > 0 do
      highest_scoring_player = Enum.max_by(players, fn(p) -> total_points_scored(p) end)
      total_points_scored(highest_scoring_player)
    end
  end

  @doc """
  Name of the player with the most all-time points.
  """
  @spec most_points_name :: string
  def most_points_name do
    players = Repo.all(Player)
    if Enum.count(players) > 0 do
      highest_scoring_player = Enum.max_by(players, fn(p) -> total_points_scored(p) end)
      highest_scoring_player.name
    end
  end
end
