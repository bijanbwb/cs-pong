defmodule Pong.PlayerController do
  use Pong.Web, :controller

  alias Pong.Player
  alias Pong.Match

  plug :scrub_params, "player" when action in [:create, :update]

  def index(conn, _params) do
    players = Repo.all(Player)
    matches = Match
    |> preload([:player_a, :player_b])
    |> Repo.all
    render(conn, "index.html", players: players, matches: matches)
  end

  def new(conn, _params) do
    changeset = Player.changeset(%Player{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"player" => player_params}) do
    changeset = Player.changeset(%Player{}, player_params)

    case Repo.insert(changeset) do
      {:ok, _player} ->
        conn
        |> put_flash(:info, "Player created successfully.")
        |> redirect(to: player_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    player = Repo.get!(Player, id)

    matches = Match
    |> preload([:player_a, :player_b])
    |> Repo.all

    render(conn, "show.html", player: player, matches: matches)
  end

  def edit(conn, %{"id" => id}) do
    player = Repo.get!(Player, id)
    changeset = Player.changeset(player)
    render(conn, "edit.html", player: player, changeset: changeset)
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    player = Repo.get!(Player, id)
    changeset = Player.changeset(player, player_params)

    case Repo.update(changeset) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player updated successfully.")
        |> redirect(to: player_path(conn, :show, player))
      {:error, changeset} ->
        render(conn, "edit.html", player: player, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    player = Repo.get!(Player, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(player)

    conn
    |> put_flash(:info, "Player deleted successfully.")
    |> redirect(to: player_path(conn, :index))
  end
end
