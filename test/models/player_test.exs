defmodule Pong.PlayerTest do
  use Pong.ModelCase

  alias Pong.Player

  @valid_attrs %{name: "PlayerFirstName PlayerLastName", avatar_url: "https://codeschool-directory.s3.amazonaws.com/uploads/member/portrait/18/something.jpg"}
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
