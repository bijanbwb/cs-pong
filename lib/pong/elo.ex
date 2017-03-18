defmodule Pong.Elo do
  @moduledoc """
  We use this module to calculate relative rankings between players. These
  rankings are based on the Elo algorithm, and use a provisional player status
  to help combat rank inflation.
  
  The Elo algorithm is relative, meaning scores are calculated recursively
  (based on the previous score and the results of the current match) rather than
  by looking at the absolute picture of match history. There are a few
  implementation details worth noting:
  
  Every player will begin with a ranking of 1000. This serves as the ranking
  of a player with "average" skill with one caveat: over time, as new players
  are introduced (and presumably get better over time), the average will
  increase because their initial ranking doesn't reflect true skill. To help
  combat this, players are considered "provisional" for their first ten games.
  During this period, the results of their matches will not affect the rankings
  of their opponents. This hopefully gives enough time for the initial ranking
  to move closer to the player's actual skill prior to influencing the global
  scope. (With the exception of new-player inflation and the variable K factor,
  Elo is zero-sum.)
  """
  
  alias Pong.{Match, Player}

  @spec calculate_ranks(Match, {Player, Player}) :: {float, float}
  def calculate_ranks(match, {player_a, player_b}) do
    {rank_a, rank_b} = {player_a.ranking, player_b.ranking}
    {expected_a, expected_b} = expected_score(rank_a, rank_b)
    
    # The "score" is a ratio of points.
    score_total = match.player_a_points + match.player_b_points
    score_a = match.player_a_points / score_total
    score_b = match.player_b_points / score_total
    
    # New rank depends on the player's K factor.
    rank_a_new = rank_a + k_factor(rank_a) * (score_a - expected_a)
    rank_b_new = rank_b + k_factor(rank_b) * (score_b - expected_b)
    
    # Provisional players do not affect the rankings of non-provisional players.
    cond do
      player_a.provisional and not player_b.provisional ->
        {rank_a_new, rank_b}
      
      player_b.provisional and not player_a.provisional ->
        {rank_a, rank_b_new}
      
      true ->
        {rank_a_new, rank_b_new}
    end
  end
  
  @doc """
  Calculates the expected outcome of a match based on player rankings.
  
  A difference in 200 ranking points equals approximately a 75%/25% chance of
  winning the match.
  """
  @spec expected_score(float, float) :: {float, float}
  def expected_score(rank_a, rank_b) do
    expected_a = 1 / (1 + :math.pow(10, (rank_b - rank_a) / 400))
    expected_b = 1 / (1 + :math.pow(10, (rank_a - rank_b) / 400))
    
    {expected_a, expected_b}
  end
  
  @doc """
  Calculates the K factor (maximum possible number of points gained or lost in
  a single game).
  
  For this we use a linear change centered around the (supposed) average of 1000
  ranking points. If the true average ranking changes over time due to new
  player inflation or retired player deflation (or another unforeseen change in
  the value of ranking points), this calculation may need to take into account
  the new average. Since games are rarely shut-outs, the K factors should be
  relatively high (otherwise rankings change very slowly).
  
  We wish to have the following piece-wise function:
  
  ------------------------
  | Ranking   | K Factor |
  |-----------|----------|
  | 0-600     |    36    |
  | 600-1400  | 36 -> 28 |
  | 1400-2000 |    28    |
  ------------------------
  """
  @spec k_factor(float) :: float
  def k_factor(rank) do
    case rank do
      x when x < 600 ->
        36.0
    
      x when x < 1400 ->
        32.0 + (1000.0 - rank) / 100.0
    
      _ ->
        28.0
    end
  end
  
  @doc """
  Update players' rankings based on the results of a match.
  """
  @spec update_ranks(Match, {Player, Player}) :: nil
  def update_ranks(match, {player_a, player_b}) do
    {rank_a, rank_b} = calculate_ranks(match, {player_a, player_b})
    
    changeset_a = %{ranking: rank_a, games: player_a.games + 1}
    changeset_b = %{ranking: rank_b, games: player_b.games + 1}
    
    changeset_a = cond do
      player_a.games > 9 ->
        Map.put(changeset_a, :provisional, false)
      
      true ->
        changeset_a
    end
    
    changeset_b = cond do
      player_b.games > 9 ->
        Map.put(changeset_b, :provisional, false)
      
      true ->
        changeset_b
    end
    
    player_a
    |> Player.rank_changeset(changeset_a)
    |> Pong.Repo.update!
    
    player_b
    |> Player.rank_changeset(changeset_b)
    |> Pong.Repo.update!
    
    # For debugging initial migrations:
    # IO.puts(:standard_error, "Match #{match.id} :: #{player_a.name} "
    # <> "(#{rank_a}) #{match.player_a_points} - #{match.player_b_points} "
    # <> "#{player_b.name} (#{rank_b})")
    
    nil
  end
end