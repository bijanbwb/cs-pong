defmodule Pong.PlayerView do
  use Pong.Web, :view

  import Ecto.Query, only: [from: 2]

  alias Pong.Match
  alias Pong.MatchView
  alias Pong.Player
  alias Pong.Repo

  ## -------------------------------------
  ##   Basic Player Data
  ## -------------------------------------

  @doc """
  Player avatar from user-entered URL. Or default avatar if one has not been
  entered yet.
  """
  @spec avatar(Player) :: String
  def avatar(%Player{id: id}) do
    player = Repo.get(Player, id)
    if player.avatar_url, do: player.avatar_url, else: "/images/default_avatar.png"
  end

  ## -------------------------------------
  ##   Player Match Data
  ## -------------------------------------

  @doc """
  Total number of games played for the player.
  """
  @spec total_matches(Player) :: integer
  def total_matches(%Player{id: id}) do
    player = Repo.get(Player, id)
    wins(player) + losses(player)
  end

  @doc """
  Date of the most recent match played.
  """
  @spec most_recent_match_date(Player) :: String
  def most_recent_match_date(%Player{id: id}) do
    player = Repo.get(Player, id)
    recent_matches = recent_matches(player)
    if Enum.count(recent_matches) > 0, do: Ecto.DateTime.to_date(List.last(recent_matches).inserted_at)
  end

  ## -------------------------------------
  ##   Player Win and Loss Data
  ## -------------------------------------

  @doc """
  Total number of wins for the player.
  """
  @spec wins(Player) :: integer
  def wins(%Player{id: id}) do
    player = Repo.get(Player, id)
    Repo.all(Match)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_win_id(m) end)
    |> Enum.count
  end

  @doc """
  Total number of losses for the player.
  """
  @spec losses(Player) :: integer
  def losses(%Player{id: id}) do
    player = Repo.get(Player, id)
    Repo.all(Match)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_loss_id(m) end)
    |> Enum.count
  end

  @doc """
  Win-loss percentage as a string value.
  """
  @spec win_loss_percentage(Player) :: String
  def win_loss_percentage(%Player{id: id}) do
    player = Repo.get(Player, id)
    if total_matches(player) > 0, do: Float.to_string(wins(player) / total_matches(player) * 100, decimals: 0) <> "%", else: "0%"
  end

  @doc """
  Win-loss percentage as a float from 0.0 to 100.0.
  """
  @spec win_loss_percentage_number(Player) :: Float
  def win_loss_percentage_number(%Player{id: id}) do
    player = Repo.get(Player, id)
    if total_matches(player) > 0, do: wins(player) / total_matches(player) * 100
  end

  ## -------------------------------------
  ##   Player Points Data
  ## -------------------------------------

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
    if differential > 0, do: "+" <> Integer.to_string(differential), else: differential
  end

  ## -------------------------------------
  ##   Player Stats
  ## -------------------------------------

  @doc """
  The player with the highest win percentage is the current champion.
  """
  @spec current_champion :: Player
  def current_champion do
    List.first(players_by_percentage)
  end

  @doc """
  Win-loss percentage for the player with the highest all-time value.
  """
  @spec highest_win_percentage :: String
  def highest_win_percentage do
    players = Repo.all(Player)
    players_with_results = Enum.filter(players, fn(p) -> total_matches(p) > 0 end)
    if Enum.count(players_with_results) > 0 do
      Enum.max_by(players_with_results, fn(p) -> win_loss_percentage_number(p) end)
      |> win_loss_percentage
    end
  end

  @doc """
  Name of the player with the highest all-time win percentage.
  """
  @spec highest_win_percentage_name :: String
  def highest_win_percentage_name do
    players = Repo.all(Player)
    players_with_results = Enum.filter(players, fn(p) -> total_matches(p) > 0 end)
    if Enum.count(players_with_results) > 0 do
      player_with_highest_percentage = Enum.max_by(players_with_results, fn(p) -> win_loss_percentage_number(p) end)
      player_with_highest_percentage.name
    end
  end

  @doc """
  Number of wins for the player with the most all-time wins.
  """
  @spec most_wins :: String
  def most_wins do
    players = Repo.all(Player)
    if Enum.count(players) > 0 do
      Enum.max_by(players, fn(p) -> wins(p) end)
      |> wins
    end
  end

  @doc """
  Name of the player with the most all-time wins.
  """
  @spec most_wins_name :: String
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
  @spec most_points :: String
  def most_points do
    players = Repo.all(Player)
    if Enum.count(players) > 0 do
      Enum.max_by(players, fn(p) -> total_points_scored(p) end)
      |> total_points_scored
    end
  end

  @doc """
  Name of the player with the most all-time points.
  """
  @spec most_points_name :: String
  def most_points_name do
    players = Repo.all(Player)
    if Enum.count(players) > 0 do
      highest_scoring_player = Enum.max_by(players, fn(p) -> total_points_scored(p) end)
      highest_scoring_player.name
    end
  end

  ## -------------------------------------
  ##   Player Lists
  ## -------------------------------------

  @doc """
  List of recent matches that the player has participated in.
  """
  @spec recent_matches(Player) :: List
  def recent_matches(%Player{id: id}) do
    player = Repo.get(Player, id)
    Repo.all(Match)
    |> Enum.filter(fn(m) -> player.id == m.player_a_id || player.id == m.player_b_id end)
  end

  @doc """
  Matches lost by player.
  """
  @spec matches_lost(Player) :: List
  def matches_lost(%Player{id: id}) do
    player = Repo.get(Player, id)
    recent_matches(player)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_loss_id(m) end)
  end

  @doc """
  List of ids for players that have been lost to.
  """
  @spec players_lost_to(Player) :: List
  def players_lost_to(%Player{id: id}) do
    players_lost_to = []
    player = Repo.get(Player, id)
    |> matches_lost
    |> Enum.map(fn(m) -> players_lost_to ++ MatchView.player_win_id(m) end)
  end

  @doc """
  List of players sorted by their win percentage.

  This function is impressively obfuscated even though it is meant to accomplish
  something simple.
  """
  @spec players_by_percentage :: List
  def players_by_percentage do
    players = Repo.all(Player)
    players_with_results = Enum.filter(players, fn(p) -> total_matches(p) > 0 end)
    players_without_results = Enum.filter(players, fn(p) -> total_matches(p) == 0 end)
    players_by_percentage = Enum.reverse(Enum.sort_by(players_with_results, fn(p) -> win_loss_percentage_number(p) end))
    players_by_percentage ++ players_without_results
  end
end
