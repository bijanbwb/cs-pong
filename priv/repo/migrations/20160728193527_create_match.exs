defmodule Pong.Repo.Migrations.CreateMatch do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :player_a_id, :integer
      add :player_b_id, :integer
      add :player_a_points, :integer
      add :player_b_points, :integer
      add :player_win_id, :integer
      add :player_loss_id, :integer
      add :total_points, :integer
      add :overtime, :boolean, default: false, null: false

      timestamps()
    end

  end
end
