defmodule Pong.Match do
  use Pong.Web, :model

  schema "matches" do
    field :player_a_id, :integer
    field :player_b_id, :integer
    field :player_a_points, :integer
    field :player_b_points, :integer
    field :player_win_id, :integer
    field :player_loss_id, :integer
    field :total_points, :integer
    field :overtime, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:player_a_id, :player_b_id, :player_a_points, :player_b_points, :player_win_id, :player_loss_id, :total_points, :overtime])
    |> validate_required([:player_a_id, :player_b_id, :player_a_points, :player_b_points, :player_win_id, :player_loss_id, :total_points, :overtime])
  end
end
