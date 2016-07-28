defmodule Pong.PlayerTest do
  use Pong.ModelCase

  alias Pong.Player

  @valid_attrs %{avatar_url: "some content", losses: 42, name: "some content", total_matches: 42, total_points: 42, total_points_against: 42, total_points_differential: 42, wins: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Player.changeset(%Player{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Player.changeset(%Player{}, @invalid_attrs)
    refute changeset.valid?
  end
end
