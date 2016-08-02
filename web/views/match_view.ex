defmodule Pong.MatchView do
  use Pong.Web, :view

  alias Pong.Match
  alias Pong.Player
  alias Pong.PlayerView
  alias Pong.Repo

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
  The sum of all points scored by two players in a match.
  """
  @spec match_points(Match) :: integer
  def match_points(%Match{id: id}) do
    match = Repo.get(Match, id)
    match.player_a_points + match.player_b_points
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

  @doc """
  All-time total number of matches played for all players.
  """
  @spec total_matches :: integer
  def total_matches do
    matches = Repo.all(Match)
    Enum.count(matches)
  end

  @doc """
  All-time total number of points scored in all matches.
  """
  @spec total_points :: integer
  def total_points do
    matches = Repo.all(Match)
    Enum.reduce(matches, 0, fn(m, acc) -> m.player_a_points + m.player_b_points + acc end)
  end

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
  List of all matches sorted in reverse by creation date.
  """
  @spec matches_sorted :: List
  def matches_sorted do
    Repo.all(Match)
    |> Enum.sort
    |> Enum.reverse
  end
end
