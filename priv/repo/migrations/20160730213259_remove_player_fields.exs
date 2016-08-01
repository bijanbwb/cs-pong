defmodule Pong.Repo.Migrations.RemovePlayerFields do
  use Ecto.Migration

  def change do
    alter table(:players) do
      remove :wins
      remove :losses
      remove :total_matches
      remove :total_points
      remove :total_points_against
      remove :total_points_differential
    end
  end
end
