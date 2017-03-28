defmodule Pong.MatchView do
  use Pong.Web, :view
  use Timex

  alias Pong.Match
  alias Pong.Player
  alias Pong.PlayerView
  alias Pong.Repo

  ## -------------------------------------
  ##   Basic Player Data
  ## -------------------------------------

  @doc """
  The name of Player A in a match.
  """
  @spec player_a_name(Match) :: String
  def player_a_name(match) do
    case match.player_a do
      %{name: name} ->
        name
      _ ->
        nil
    end
  end

  @doc """
  The name of Player B in a match.
  """
  @spec player_b_name(Match) :: String
  def player_b_name(match) do
    case match.player_b do
      %{name: name} ->
        name
      _ ->
        nil
    end
  end

  @doc """
  The avatar for Player A in a match.
  """
  @spec player_a_avatar(Match) :: String
  def player_a_avatar(match) do
    PlayerView.avatar(match.player_a)
  end

  @doc """
  The avatar for Player B in a match.
  """
  @spec player_b_avatar(Match) :: String
  def player_b_avatar(match) do
    PlayerView.avatar(match.player_b)
  end

  ## -------------------------------------
  ##   Player Win and Loss Data
  ## -------------------------------------

  @doc """
  The winning player of a match.
  """
  @spec player_winner(Match) :: Player
  def player_winner(match) do
    cond do
      match.player_a_points > match.player_b_points ->
        match.player_a
      true ->
        match.player_b
    end
  end

  @doc """
  The losing player of a match.
  """
  @spec player_loser(Match) :: Player
  def player_loser(match) do
    cond do
      match.player_a_points > match.player_b_points ->
        match.player_b
      true ->
        match.player_a
    end
  end

  @doc """
  The id of the player who won the match.
  """
  @spec player_win_id(Match) :: integer
  def player_win_id(match) do
    if match.player_a_points > match.player_b_points, do: match.player_a_id, else: match.player_b_id
  end

  @doc """
  The id of the player who lost the match.
  """
  @spec player_loss_id(Match) :: integer
  def player_loss_id(match) do
    if match.player_a_points > match.player_b_points, do: match.player_b_id, else: match.player_a_id
  end

  @doc """
  The name of the player who won the match.
  """
  @spec player_win_name(Match) :: String
  def player_win_name(match) do
    player_winner(match)
    |> Map.fetch!(:name)
  end

  @doc """
  The name of the player who lost the match.
  """
  @spec player_loss_name(Match) :: String
  def player_loss_name(match) do
    player_loser(match)
    |> Map.fetch!(:name)
  end

  @doc """
  Returns a string to use as a class name for when Player A won or lost the
  match so that it can be styled in the template.
  """
  @spec player_a_win_loss_class(Match) :: String
  def player_a_win_loss_class(match) do
    if player_a_win?(match), do: "match-win" , else: "match-loss"
  end

  @doc """
  Returns a string to use as a class name for when Player B won or lost the
  match so that it can be styled in the template.
  """
  @spec player_b_win_loss_class(Match) :: String
  def player_b_win_loss_class(match) do
    if player_b_win?(match), do: "match-win" , else: "match-loss"
  end

  ## -------------------------------------
  ##   Point Data
  ## -------------------------------------

  @doc """
  The sum of all points scored by two players in a match.
  """
  @spec match_points(Match) :: integer
  def match_points(match) do
    match.player_a_points + match.player_b_points
  end

  ## -------------------------------------
  ##   Predicate Functions
  ## -------------------------------------

  @doc """
  Determines whether or not Player A was the winner of the match.
  """
  @spec player_a_win?(Match) :: boolean
  def player_a_win?(match) do
    match.player_a_points > match.player_b_points
  end

  @doc """
  Determines whether or not Player B was the winner of the match.
  """
  @spec player_b_win?(Match) :: boolean
  def player_b_win?(match) do
    match.player_a_points < match.player_b_points
  end

  @doc """
  Determines whether or not a match went into overtime based on the total
  number of points scored by both players.
  """
  @spec overtime?(Match) :: boolean
  def overtime?(match) do
    if match_points(match) > 40, do: True
  end

  ## -------------------------------------
  ##   Stats
  ## -------------------------------------

  @doc """
  All-time total number of matches played for all players.
  """
  @spec total_matches(List) :: integer
  def total_matches(matches) do
    matches
    |> Enum.count
  end

  @doc """
  All-time total number of points scored in all matches.
  """
  @spec total_points(List) :: integer
  def total_points(matches) do
    matches
    |> Enum.reduce(0, fn(m, acc) -> m.player_a_points + m.player_b_points + acc end)
  end

  @doc """
  All-time total number of overtime matches.
  """
  @spec overtime_matches(List) :: integer
  def overtime_matches(matches) do
    matches
    |> Enum.filter(fn (m) -> overtime?(m) end)
    |> Enum.count
  end

  @doc """
  Number of wins for Player A in matches between two specific players.
  """
  @spec matches_between_players_a_wins(List, Match) :: List
  def matches_between_players_a_wins(matches, match) do
    matches_between_players(matches, match)
    |> Enum.filter(fn(m) -> player_win_id(m) == match.player_a_id end)
    |> Enum.count
  end

  @doc """
  Number of wins for Player B in matches between two specific players.
  """
  @spec matches_between_players_b_wins(List, Match) :: List
  def matches_between_players_b_wins(matches, match) do
    matches_between_players(matches, match)
    |> Enum.filter(fn(m) -> player_win_id(m) == match.player_b_id end)
    |> Enum.count
  end

  @doc """
  Number of overtime games for matches between two specific players.
  """
  @spec matches_between_players_ot_games(List, Match) :: List
  def matches_between_players_ot_games(matches, match) do
    matches_between_players(matches, match)
    |> Enum.filter(fn(m) -> overtime?(m) end)
    |> Enum.count
  end

  ## -------------------------------------
  ##   Lists
  ## -------------------------------------

  @doc """
  List of all player names mapped to their ids for the match form.
  """
  @spec player_list :: List
  def player_list do
    player_list = []
    Repo.all(Player)
    |> Enum.map(fn(p) -> player_list ++ {p.name, p.id} end)
  end

  @doc """
  List of all player ids.
  """
  @spec player_ids :: List
  def player_ids do
    player_ids = []
    Repo.all(Player)
    |> Enum.map(fn(p) -> player_ids ++ p.id end)
  end

  @doc """
  List of all matches sorted in reverse by `inserted_at` date.
  """
  @spec matches_sorted(List) :: List
  def matches_sorted(matches) do
    matches
    |> Enum.sort
    |> Enum.reverse
  end

  @doc """
  List of all previous matches between both participating players in a match.
  """
  @spec matches_between_players(List, Match) :: List
  def matches_between_players(matches, match) do
    Enum.filter(matches, fn(m) -> m.player_a_id == match.player_a_id && m.player_b_id == match.player_b_id || m.player_b_id == match.player_a_id && m.player_a_id == match.player_b_id end)
  end

  @doc """
  Finds the most recent Sunday to use for determining which matches occurred
  in the current week.

  Seems like there would have to be an easier way to do this, but I
  unsuccessfully spent a decent amount of time trying to find it.
  """
  @spec find_last_sunday :: Date
  def find_last_sunday do
    cond do
      Timex.weekday(Timex.today) == 1 ->
        Timex.shift(Timex.today, days: -1)
      Timex.weekday(Timex.today) == 2 ->
        Timex.shift(Timex.today, days: -2)
      Timex.weekday(Timex.today) == 3 ->
        Timex.shift(Timex.today, days: -3)
      Timex.weekday(Timex.today) == 4 ->
        Timex.shift(Timex.today, days: -4)
      Timex.weekday(Timex.today) == 5 ->
        Timex.shift(Timex.today, days: -5)
      Timex.weekday(Timex.today) == 6 ->
        Timex.shift(Timex.today, days: -6)
      Timex.weekday(Timex.today) == 7 ->
        Timex.shift(Timex.today, days: -7)
    end
  end

  @doc """
  List of matches played this week. The current week starts on Monday mornings.
  """
  @spec matches_this_week(List) :: List
  def matches_this_week(matches) do
    Enum.filter(matches, fn(m) -> Timex.after?(m.inserted_at |> Ecto.DateTime.to_date |> Ecto.Date.to_erl |> Date.from_erl |> elem(1), find_last_sunday) end)
  end

  @doc """
  Finds the number of the current month.

  Seems like there would have to be an easier way to do this, but I
  unsuccessfully spent a decent amount of time trying to find it.
  """
  @spec find_current_month :: Integer
  def find_current_month do
    DateTime.utc_now
    |> DateTime.to_date
    |> Date.to_erl
    |> elem(1)
  end

  @doc """
  List of matches played in the current month.
  """
  @spec matches_this_month(List) :: List
  def matches_this_month(matches) do
    Enum.filter(matches, fn(m) -> m.inserted_at |> Ecto.DateTime.to_date |> Ecto.Date.dump |> elem(1) |> elem(1) == find_current_month end)
  end
end
