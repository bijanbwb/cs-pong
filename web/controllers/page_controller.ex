defmodule Pong.PageController do
  use Pong.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
