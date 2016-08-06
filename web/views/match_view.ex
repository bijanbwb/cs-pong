defmodule Pong.MatchView do
  use Pong.Web, :view

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
  def player_a_name(%Match{id: id}) do
    match = Repo.get(Match, id)
    players = Repo.all(Player)
    player = Enum.find(players, fn(p) -> p.id == match.player_a_id end)
    if player, do: player.name
  end

  @doc """
  The name of Player B in a match.
  """
  @spec player_b_name(Match) :: String
  def player_b_name(%Match{id: id}) do
    match = Repo.get(Match, id)
    players = Repo.all(Player)
    player = Enum.find(players, fn(p) -> p.id == match.player_b_id end)
    if player, do: player.name
  end

  @doc """
  The avatar for Player A in a match.
  """
  @spec player_a_avatar(Match) :: String
  def player_a_avatar(%Match{id: id}) do
    match = Repo.get(Match, id)
    player_a = Repo.get(Player, match.player_a_id)
    if player_a do
      PlayerView.avatar(player_a)
    else
      "/images/default_avatar.png"
    end
  end

  @doc """
  The avatar for Player B in a match.
  """
  @spec player_b_avatar(Match) :: String
  def player_b_avatar(%Match{id: id}) do
    match = Repo.get(Match, id)
    player_b = Repo.get(Player, match.player_b_id)
    if player_b do
      PlayerView.avatar(player_b)
    else
      "/images/default_avatar.png"
    end
  end

  ## -------------------------------------
  ##   Player Win and Loss Data
  ## -------------------------------------

  @doc """
  The id of the player who won the match.
  """
  @spec player_win_id(Match) :: integer
  def player_win_id(%Match{id: id}) do
    match = Repo.get(Match, id)
    if match.player_a_points > match.player_b_points do
      match.player_a_id
    else
      match.player_b_id
    end
  end

  @doc """
  The id of the player who lost the match.
  """
  @spec player_loss_id(Match) :: integer
  def player_loss_id(%Match{id: id}) do
    match = Repo.get(Match, id)
    if match.player_a_points > match.player_b_points do
      match.player_b_id
    else
      match.player_a_id
    end
  end

  @doc """
  The name of the player who won the match.
  """
  @spec player_win_name(Match) :: String
  def player_win_name(%Match{id: id}) do
    match = Repo.get(Match, id)
    players = Repo.all(Player)
    player = Enum.find(players, fn(p) -> p.id == player_win_id(match) end)
    if player, do: player.name
  end

  @doc """
  The name of the player who lost the match.
  """
  @spec player_loss_name(Match) :: String
  def player_loss_name(%Match{id: id}) do
    match = Repo.get(Match, id)
    players = Repo.all(Player)
    player = Enum.find(players, fn(p) -> p.id == player_loss_id(match) end)
    if player, do: player.name
  end

  @doc """
  Returns a string to use as a class name for when Player A won or lost the
  match so that it can be styled in the template.
  """
  @spec player_a_win_loss_class(Match) :: String
  def player_a_win_loss_class(%Match{id: id}) do
    match = Repo.get(Match, id)
    if player_a_win?(match), do: "match-win" , else: "match-loss"
  end

  @doc """
  Returns a string to use as a class name for when Player B won or lost the
  match so that it can be styled in the template.
  """
  @spec player_b_win_loss_class(Match) :: String
  def player_b_win_loss_class(%Match{id: id}) do
    match = Repo.get(Match, id)
    if player_b_win?(match), do: "match-win" , else: "match-loss"
  end

  ## -------------------------------------
  ##   Point Data
  ## -------------------------------------

  @doc """
  The sum of all points scored by two players in a match.
  """
  @spec match_points(Match) :: integer
  def match_points(%Match{id: id}) do
    match = Repo.get(Match, id)
    match.player_a_points + match.player_b_points
  end

  ## -------------------------------------
  ##   Predicate Functions
  ## -------------------------------------

  @doc """
  Determines whether or not Player A was the winner of the match.
  """
  @spec player_a_win?(Match) :: boolean
  def player_a_win?(%Match{id: id}) do
    match = Repo.get(Match, id)
    if match.player_a_id == player_win_id(match), do: True
  end

  @doc """
  Determines whether or not Player B was the winner of the match.
  """
  @spec player_b_win?(Match) :: boolean
  def player_b_win?(%Match{id: id}) do
    match = Repo.get(Match, id)
    if match.player_b_id == player_win_id(match), do: True
  end

  @doc """
  Determines whether or not a match went into overtime based on the total
  number of points scored by both players.
  """
  @spec overtime?(Match) :: boolean
  def overtime?(%Match{id: id}) do
    match = Repo.get(Match, id)
    if match_points(match) > 40, do: True
  end

  ## -------------------------------------
  ##   Stats
  ## -------------------------------------

  @doc """
  All-time total number of matches played for all players.
  """
  @spec total_matches :: integer
  def total_matches do
    Repo.all(Match)
    |> Enum.count
  end

  @doc """
  All-time total number of points scored in all matches.
  """
  @spec total_points :: integer
  def total_points do
    Repo.all(Match)
    |> Enum.reduce(0, fn(m, acc) -> m.player_a_points + m.player_b_points + acc end)
  end

  @doc """
  All-time total number of overtime matches.
  """
  @spec overtime_matches :: integer
  def overtime_matches do
    Repo.all(Match)
    |> Enum.filter(fn (m) -> overtime?(m) end)
    |> Enum.count
  end

  @doc """
  Number of wins for Player A in matches between two specific players.
  """
  @spec matches_between_players_a_wins(Match) :: List
  def matches_between_players_a_wins(%Match{id: id}) do
    match = Repo.get(Match, id)
    matches_between_players(match)
    |> Enum.filter(fn(m) -> player_win_id(match) == match.player_a_id end)
    |> Enum.count
  end

  @doc """
  Number of wins for Player B in matches between two specific players.
  """
  @spec matches_between_players_b_wins(Match) :: List
  def matches_between_players_b_wins(%Match{id: id}) do
    match = Repo.get(Match, id)
    matches_between_players(match)
    |> Enum.filter(fn(m) -> player_win_id(match) == match.player_b_id end)
    |> Enum.count
  end

  @doc """
  Number of overtime games for matches between two specific players.
  """
  @spec matches_between_players_ot_games(Match) :: List
  def matches_between_players_ot_games(%Match{id: id}) do
    Repo.get(Match, id)
    |> matches_between_players
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
    players = Repo.all(Player)
    player_list = []
    Enum.map(players, fn(p) -> player_list ++ {p.name, p.id} end)
  end

  @doc """
  List of all player ids.
  """
  @spec player_ids :: List
  def player_ids do
    players = Repo.all(Player)
    player_ids = []
    Enum.map(players, fn(p) -> player_ids ++ p.id end)
  end

  @doc """
  List of all matches sorted in reverse by `inserted_at` date.
  """
  @spec matches_sorted :: List
  def matches_sorted do
    Repo.all(Match)
    |> Enum.sort
    |> Enum.reverse
  end

  @doc """
  List of all previous matches between both participating players in a match.
  """
  @spec matches_between_players(Match) :: List
  def matches_between_players(%Match{id: id}) do
    match = Repo.get(Match, id)
    all_matches = Repo.all(Match)
    matches_between_a = Enum.filter(all_matches, fn(m) -> m.player_a_id == match.player_a_id && m.player_b_id == match.player_b_id end)
    matches_between_b = Enum.filter(all_matches, fn(m) -> m.player_b_id == match.player_a_id && m.player_a_id == match.player_b_id end)
    matches_between_a ++ matches_between_b
  end
end
