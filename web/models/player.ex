defmodule Pong.Player do
  use Pong.Web, :model

  schema "players" do
    field :name, :string
    field :avatar_url, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :avatar_url])
    |> validate_required([:name])
  end
end
