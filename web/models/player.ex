defmodule Pong.Player do
  use Pong.Web, :model

  schema "players" do
    field :name, :string
    field :avatar_url, :string
    field :games, :integer, default: 0
    field :ranking, :float, default: 1000.0
    field :provisional, :boolean, default: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :avatar_url,])
    |> validate_required([:name])
  end

  @doc """
  Builds a changeset for use by the rank calculator.
  """
  def rank_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:games, :ranking, :provisional])
  end
end
