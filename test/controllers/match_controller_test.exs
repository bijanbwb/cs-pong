defmodule Pong.MatchControllerTest do
  use Pong.ConnCase

  alias Pong.Match
  alias Pong.Player

  @valid_attrs %{player_a_id: 1, player_b_id: 2, player_a_points: 21, player_b_points: 19}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, match_path(conn, :index)
    assert html_response(conn, 200) =~ "Match History"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, match_path(conn, :new)
    assert html_response(conn, 200) =~ "New Match"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, match_path(conn, :create), match: @valid_attrs
    assert redirected_to(conn) == match_path(conn, :index)
    assert Repo.get_by(Match, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, match_path(conn, :create), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Match"
  end

  test "shows chosen resource", %{conn: conn} do
    player_a = Repo.insert! %Player{}
    player_b = Repo.insert! %Player{}
    match = Repo.insert! %Match{player_a_id: player_a.id, player_b_id: player_b.id}
    conn = get conn, match_path(conn, :show, match)
    assert html_response(conn, 200) =~ "Match"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, match_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :edit, match)
    assert html_response(conn, 200) =~ "Edit Match"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @valid_attrs
    assert redirected_to(conn) == match_path(conn, :show, match)
    assert Repo.get_by(Match, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Match"
  end

  test "deletes chosen resource", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = delete conn, match_path(conn, :delete, match)
    assert redirected_to(conn) == match_path(conn, :index)
    refute Repo.get(Match, match.id)
  end
end
