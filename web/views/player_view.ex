defmodule Pong.PlayerView do
  use Pong.Web, :view

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
  def avatar(player) do
    if player.avatar_url, do: player.avatar_url, else: "/images/default_avatar.png"
  end

  ## -------------------------------------
  ##   Player Match Data
  ## -------------------------------------

  @doc """
  Total number of games played for the player.
  """
  @spec total_matches(Player) :: integer
  def total_matches(player) do
    wins(player) + losses(player)
  end

  @doc """
  Date of the most recent match played.
  """
  @spec most_recent_match_date(Player) :: String
  def most_recent_match_date(player) do
    recent_matches = recent_matches(player)
    if Enum.count(recent_matches) > 0, do: Ecto.DateTime.to_date(List.last(recent_matches).inserted_at), else: "No Games"
  end

  ## -------------------------------------
  ##   Player Win and Loss Data
  ## -------------------------------------

  @doc """
  Total number of wins for the player.
  """
  @spec wins(Player) :: integer
  def wins(player) do
    Repo.all(Match)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_win_id(m) end)
    |> Enum.count
  end

  @doc """
  Total number of losses for the player.
  """
  @spec losses(Player) :: integer
  def losses(player) do
    Repo.all(Match)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_loss_id(m) end)
    |> Enum.count
  end

  @doc """
  Win-loss percentage as a string value.
  """
  @spec win_loss_percentage(Player) :: String
  def win_loss_percentage(player) do
    if total_matches(player) > 0, do: Float.to_string(wins(player) / total_matches(player) * 100, decimals: 0) <> "%", else: "0%"
  end

  @doc """
  Win-loss percentage as a float from 0.0 to 100.0.
  """
  @spec win_loss_percentage_number(Player) :: Float
  def win_loss_percentage_number(player) do
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
  def total_points_scored(player) do
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
  def total_points_against(player) do
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
  def total_points_differential(player) do
    differential = total_points_scored(player) - total_points_against(player)
    if differential > 0, do: "+" <> Integer.to_string(differential), else: differential
  end

  ## -------------------------------------
  ##   Global Player Stats
  ## -------------------------------------

  @doc """
  The player with the highest win percentage is the current champion.
  """
  @spec current_champion(List) :: Player
  def current_champion(players) do
    if Enum.count(players_by_percentage(players)) > 0, do: List.first(players_by_percentage(players))
  end

  @doc """
  The player with the highest all-time win percentage value.
  """
  @spec highest_win_percentage(List) :: Player
  def highest_win_percentage(players) do
    players_with_results = Enum.filter(players, fn(p) -> total_matches(p) > 0 end)
    if Enum.count(players_with_results) > 0, do: Enum.max_by(players_with_results, fn(p) -> win_loss_percentage_number(p) end)
  end

  @doc """
  Name of the player with the highest all-time win percentage.
  """
  @spec highest_win_percentage_name(List) :: String
  def highest_win_percentage_name(players) do
    if highest_win_percentage(players), do: highest_win_percentage(players).name
  end

  @doc """
  The value for the highest all-time win percentage.
  """
  @spec highest_win_percentage_value(List) :: String
  def highest_win_percentage_value(players) do
    if highest_win_percentage(players), do: win_loss_percentage(highest_win_percentage(players))
  end

  @doc """
  Number of wins for the player with the most all-time wins.
  """
  @spec most_wins(List) :: String
  def most_wins(players) do
    if Enum.count(players) > 0, do: Enum.max_by(players, fn(p) -> wins(p) end) |> wins
  end

  @doc """
  Name of the player with the most all-time wins.
  """
  @spec most_wins_name(List) :: String
  def most_wins_name(players) do
    if Enum.count(players) > 0 do
      winningest_player = Enum.max_by(players, fn(p) -> wins(p) end)
      winningest_player.name
    end
  end

  @doc """
  Total points for the player with the most all-time points.
  """
  @spec most_points(List) :: String
  def most_points(players) do
    if Enum.count(players) > 0 do
      Enum.max_by(players, fn(p) -> total_points_scored(p) end)
      |> total_points_scored
    end
  end

  @doc """
  Name of the player with the most all-time points.
  """
  @spec most_points_name(List) :: String
  def most_points_name(players) do
    if Enum.count(players) > 0 do
      highest_scoring_player = Enum.max_by(players, fn(p) -> total_points_scored(p) end)
      highest_scoring_player.name
    end
  end

  ## -------------------------------------
  ##   Player Rival Data
  ## -------------------------------------

  @doc """
  A rival is the player that another player has lost to the most times.
  """
  @spec rival_id(Player) :: Player
  def rival_id(player) do
    player
    |> players_lost_to
    |> Enum.reduce(nil, fn
      pair, nil ->
        pair
      {k, v}, {_, hv} when hv < v ->
        {k, v}
      _, high ->
        high
    end)
  end

  @doc """
  The name of the player that another player has lost to the most times.
  """
  @spec rival_name(Player) :: Player
  def rival_name(player) do
    if rival_id(player) do
      rival = Repo.get(Player, rival_id(player))
      rival.name
    else
      "No Rival"
    end
  end

  @doc """
  Matches against rival.
  """
  @spec matches_against_rival(Player) :: List
  def matches_against_rival(player) do
    all_matches = Repo.all(Match)
    matches_between_a = Enum.filter(all_matches, fn(m) -> m.player_a_id == player.id && m.player_b_id == rival_id(player) end)
    matches_between_b = Enum.filter(all_matches, fn(m) -> m.player_b_id == player.id && m.player_a_id == rival_id(player) end)
    matches_between_a ++ matches_between_b
  end

  @doc """
  Wins against rival.
  """
  @spec wins_against_rival(Player) :: integer
  def wins_against_rival(player) do
    matches_against_rival(player)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_win_id(m) end)
    |> Enum.count
  end

  @doc """
  Losses against rival.
  """
  @spec losses_against_rival(Player) :: integer
  def losses_against_rival(player) do
    matches_against_rival(player)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_loss_id(m) end)
    |> Enum.count
  end

  @doc """
  Record against rival.
  """
  @spec record_against_rival(Player) :: String
  def record_against_rival(player) do
    if wins_against_rival(player) > 0 || losses_against_rival(player) > 0 do
      Integer.to_string(wins_against_rival(player)) <> "-" <> Integer.to_string(losses_against_rival(player))
    else
      "No Rival"
    end
  end

  ## -------------------------------------
  ##   Player Lists
  ## -------------------------------------

  @doc """
  List of recent matches that the player has participated in.
  """
  @spec recent_matches(Player) :: List
  def recent_matches(player) do
    Repo.all(Match)
    |> Enum.filter(fn(m) -> player.id == m.player_a_id || player.id == m.player_b_id end)
  end

  @doc """
  Matches lost by player.
  """
  @spec matches_lost(Player) :: List
  def matches_lost(player) do
    recent_matches(player)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_loss_id(m) end)
  end

  @doc """
  List of ids for players that have been lost to.
  """
  @spec players_lost_to(Player) :: List
  def players_lost_to(player) do
    players_lost_to = []
    matches_lost(player)
    |> Enum.map(fn(m) -> players_lost_to ++ MatchView.player_win_id(m) end)
  end

  @doc """
  List of players sorted by their win percentage.

  This function is impressively obfuscated even though it is meant to accomplish
  something simple.
  """
  @spec players_by_percentage(List) :: List
  def players_by_percentage(players) do
    players_with_results = Enum.filter(players, fn(p) -> total_matches(p) > 0 end)
    players_without_results = Enum.filter(players, fn(p) -> total_matches(p) == 0 end)
    players_by_percentage = Enum.reverse(Enum.sort_by(players_with_results, fn(p) -> win_loss_percentage_number(p) end))
    players_by_percentage ++ players_without_results
  end
end
