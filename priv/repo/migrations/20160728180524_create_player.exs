defmodule Pong.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string
      add :avatar_url, :string
      add :wins, :integer
      add :losses, :integer
      add :total_matches, :integer
      add :total_points, :integer
      add :total_points_against, :integer
      add :total_points_differential, :integer

      timestamps()
    end

  end
end
