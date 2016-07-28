defmodule Pong.PageControllerTest do
  use Pong.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "New Match"
  end
end
