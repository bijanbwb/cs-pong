defmodule Pong.PlayerView do
  use Pong.Web, :view

  alias Pong.Player
  alias Pong.MatchView

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
  @spec total_matches(List, Player) :: integer
  def total_matches(matches, player) do
    wins(matches, player) + losses(matches, player)
  end

  @doc """
  Date of the most recent match played.
  """
  @spec most_recent_match_date(List, Player) :: String
  def most_recent_match_date(matches, player) do
    player_matches = player_matches(matches, player)
    if Enum.count(player_matches) > 0, do: Ecto.DateTime.to_date(List.last(player_matches).inserted_at), else: "No Games"
  end

  ## -------------------------------------
  ##   Player Win and Loss Data
  ## -------------------------------------

  @doc """
  Total number of wins for the player.
  """
  @spec wins(List, Player) :: integer
  def wins(matches, player) do
    matches
    |> Enum.filter(fn(m) -> player.id == MatchView.player_win_id(m) end)
    |> Enum.count
  end

  @doc """
  Total number of losses for the player.
  """
  @spec losses(List, Player) :: integer
  def losses(matches, player) do
    matches
    |> Enum.filter(fn(m) -> player.id == MatchView.player_loss_id(m) end)
    |> Enum.count
  end

  @doc """
  Win-loss percentage as a string value.
  """
  @spec win_loss_percentage(List, Player) :: String
  def win_loss_percentage(matches, player) do
    if total_matches(matches, player) > 0, do: Float.to_string(wins(matches, player) / total_matches(matches, player) * 100, decimals: 0) <> "%", else: "0%"
  end

  @doc """
  Win-loss percentage as a float from 0.0 to 100.0.
  """
  @spec win_loss_percentage_number(List, Player) :: Float
  def win_loss_percentage_number(matches, player) do
    if total_matches(matches, player) > 0, do: wins(matches, player) / total_matches(matches, player) * 100
  end

  ## -------------------------------------
  ##   Player Points Data
  ## -------------------------------------

  @doc """
  All-time total number of points scored.

  The complexity of this makes me wonder if I made a grievous error somewhere in
  the planning of this application.
  """
  @spec total_points_scored(List, Player) :: integer
  def total_points_scored(matches, player) do
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
  @spec total_points_against(List, Player) :: integer
  def total_points_against(matches, player) do
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
  @spec total_points_differential(List, Player) :: String
  def total_points_differential(matches, player) do
    differential = total_points_scored(matches, player) - total_points_against(matches, player)
    if differential > 0, do: "+" <> Integer.to_string(differential), else: differential
  end

  ## -------------------------------------
  ##   Global Player Stats
  ## -------------------------------------

  @doc """
  The player with the highest win percentage is the current champion.
  """
  @spec current_champion(List, List) :: Player
  def current_champion(matches, players) do
    if Enum.count(players_by_percentage(matches, players)) > 0, do: List.first(players_by_percentage(matches, players))
  end

  @doc """
  The player with the highest all-time win percentage value.
  """
  @spec highest_win_percentage(List, List) :: Player
  def highest_win_percentage(matches, players) do
    players_with_results = Enum.filter(players, fn(p) -> total_matches(matches, p) > 0 end)
    if Enum.count(players_with_results) > 0, do: Enum.max_by(players_with_results, fn(p) -> win_loss_percentage_number(matches, p) end)
  end

  @doc """
  Name of the player with the highest all-time win percentage.
  """
  @spec highest_win_percentage_name(List, List) :: String
  def highest_win_percentage_name(matches, players) do
    if highest_win_percentage(matches, players), do: highest_win_percentage(matches, players).name
  end

  @doc """
  The value for the highest all-time win percentage.
  """
  @spec highest_win_percentage_value(List, List) :: String
  def highest_win_percentage_value(matches, players) do
    if highest_win_percentage(matches, players), do: win_loss_percentage(matches, highest_win_percentage(matches, players))
  end

  @doc """
  Number of wins for the player with the most all-time wins.
  """
  @spec most_wins(List, List) :: String
  def most_wins(matches, players) do
    if Enum.count(players) > 0 do
      most_winning_player = Enum.max_by(players, fn(p) -> wins(matches, p) end)
      wins(matches, most_winning_player)
    end
  end

  @doc """
  Name of the player with the most all-time wins.
  """
  @spec most_wins_name(List, List) :: String
  def most_wins_name(matches, players) do
    if Enum.count(players) > 0 do
      winningest_player = Enum.max_by(players, fn(p) -> wins(matches, p) end)
      winningest_player.name
    end
  end

  @doc """
  Total points for the player with the most all-time points.
  """
  @spec most_points(List, List) :: String
  def most_points(matches, players) do
    if Enum.count(players) > 0 do
      player_with_most_points = Enum.max_by(players, fn(p) -> total_points_scored(matches, p) end)
      total_points_scored(matches, player_with_most_points)
    end
  end

  @doc """
  Name of the player with the most all-time points.
  """
  @spec most_points_name(List, List) :: String
  def most_points_name(matches, players) do
    if Enum.count(players) > 0 do
      highest_scoring_player = Enum.max_by(players, fn(p) -> total_points_scored(matches, p) end)
      highest_scoring_player.name
    end
  end

  ## -------------------------------------
  ##   Player Rival Data
  ## -------------------------------------

  @doc """
  A rival is the player that another player has lost to the most times.
  """
  @spec rival_player(List, Player) :: Player
  def rival_player(matches, player) do
    players_lost_to(matches, player)
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
  The id of the rival player.
  """
  @spec rival_id(List, Player) :: integer
  def rival_id(matches, player) do
    if rival_player(matches, player), do: rival_player(matches, player).id, else: "No Rival"
  end

  @doc """
  The name of the rival player.
  """
  @spec rival_name(List, Player) :: Player
  def rival_name(matches, player) do
    if rival_player(matches, player), do: rival_player(matches, player).name, else: "No Rival"
  end

  @doc """
  Matches against rival.
  """
  @spec matches_against_rival(List, Player) :: List
  def matches_against_rival(matches, player) do
    Enum.filter(matches, fn(m) -> m.player_a_id == player.id && m.player_b_id == rival_id(matches, player) end)
    ++
    Enum.filter(matches, fn(m) -> m.player_b_id == player.id && m.player_a_id == rival_id(matches, player) end)
  end

  @doc """
  Wins against rival.
  """
  @spec wins_against_rival(List, Player) :: integer
  def wins_against_rival(matches, player) do
    matches_against_rival(matches, player)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_win_id(m) end)
    |> Enum.count
  end

  @doc """
  Losses against rival.
  """
  @spec losses_against_rival(List, Player) :: integer
  def losses_against_rival(matches, player) do
    matches_against_rival(matches, player)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_loss_id(m) end)
    |> Enum.count
  end

  @doc """
  Record against rival.
  """
  @spec record_against_rival(List, Player) :: String
  def record_against_rival(matches, player) do
    if wins_against_rival(matches, player) > 0 || losses_against_rival(matches, player) > 0 do
      Integer.to_string(wins_against_rival(matches, player)) <> "-" <> Integer.to_string(losses_against_rival(matches, player))
    else
      "No Rival"
    end
  end

  ## -------------------------------------
  ##   Player Lists
  ## -------------------------------------

  @doc """
  List of all matches that the player has participated in.
  """
  @spec player_matches(List, Player) :: List
  def player_matches(matches, player) do
    matches
    |> Enum.filter(fn(m) -> player.id == m.player_a_id || player.id == m.player_b_id end)
  end

  @doc """
  Matches won by player.
  """
  @spec matches_won(List, Player) :: List
  def matches_won(matches, player) do
    player_matches(matches, player)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_win_id(m) end)
  end

  @doc """
  Matches lost by player.
  """
  @spec matches_lost(List, Player) :: List
  def matches_lost(matches, player) do
    player_matches(matches, player)
    |> Enum.filter(fn(m) -> player.id == MatchView.player_loss_id(m) end)
  end

  @doc """
  List of players that have been lost to.
  """
  @spec players_lost_to(List, Player) :: List
  def players_lost_to(matches, player) do
    players_lost_to = []
    matches_lost(matches, player)
    |> Enum.map(fn(m) -> players_lost_to ++ MatchView.player_winner(m) end)
  end

  @doc """
  List of players sorted by their win percentage.

  This function is impressively obfuscated even though it is meant to accomplish
  something simple.
  """
  @spec players_by_percentage(List, List) :: List
  def players_by_percentage(matches, players) do
    players_with_results = Enum.filter(players, fn(p) -> total_matches(matches, p) > 0 end)
    players_without_results = Enum.filter(players, fn(p) -> total_matches(matches, p) == 0 end)
    players_by_percentage = Enum.reverse(Enum.sort_by(players_with_results, fn(p) -> win_loss_percentage_number(matches, p) end))
    players_by_percentage ++ players_without_results
  end
end
