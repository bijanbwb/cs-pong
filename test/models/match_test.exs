defmodule Pong.MatchTest do
  use Pong.ModelCase

  alias Pong.Match

  @valid_attrs %{player_a_id: 42, player_a_points: 42, player_b_id: 42, player_b_points: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Match.changeset(%Match{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Match.changeset(%Match{}, @invalid_attrs)
    refute changeset.valid?
  end
end
