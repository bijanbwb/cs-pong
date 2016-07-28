defmodule Pong.Player do
  use Pong.Web, :model

  schema "players" do
    field :name, :string
    field :avatar_url, :string
    field :wins, :integer
    field :losses, :integer
    field :total_matches, :integer
    field :total_points, :integer
    field :total_points_against, :integer
    field :total_points_differential, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :avatar_url, :wins, :losses, :total_matches, :total_points, :total_points_against, :total_points_differential])
    |> validate_required([:name])
  end
end
