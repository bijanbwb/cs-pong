defmodule Pong.PlayerControllerTest do
  use Pong.ConnCase

  alias Pong.Player

  @valid_attrs %{avatar_url: "some content", name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, player_path(conn, :index)
    assert html_response(conn, 200) =~ "Players"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, player_path(conn, :new)
    assert html_response(conn, 200) =~ "New Player"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, player_path(conn, :create), player: @valid_attrs
    assert redirected_to(conn) == player_path(conn, :index)
    assert Repo.get_by(Player, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, player_path(conn, :create), player: @invalid_attrs
    assert html_response(conn, 200) =~ "New Player"
  end

  test "shows chosen resource", %{conn: conn} do
    player = Repo.insert! %Player{}
    conn = get conn, player_path(conn, :show, player)
    assert html_response(conn, 200) =~ "Record"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, player_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    player = Repo.insert! %Player{}
    conn = get conn, player_path(conn, :edit, player)
    assert html_response(conn, 200) =~ "Edit Player"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    player = Repo.insert! %Player{}
    conn = put conn, player_path(conn, :update, player), player: @valid_attrs
    assert redirected_to(conn) == player_path(conn, :show, player)
    assert Repo.get_by(Player, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    player = Repo.insert! %Player{}
    conn = put conn, player_path(conn, :update, player), player: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Player"
  end

  test "deletes chosen resource", %{conn: conn} do
    player = Repo.insert! %Player{}
    conn = delete conn, player_path(conn, :delete, player)
    assert redirected_to(conn) == player_path(conn, :index)
    refute Repo.get(Player, player.id)
  end
end
