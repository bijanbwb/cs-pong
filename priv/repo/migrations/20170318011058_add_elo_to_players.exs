defmodule Pong.Repo.Migrations.AddEloToPlayers do
  use Ecto.Migration

  def up do
    alter table(:players) do
      add :games, :integer, null: false, default: 0
      add :ranking, :float, null: false, default: 1000.0
      add :provisional, :boolean, null: false, default: true
    end

    create index(:players, [:ranking])
  end

  def down do
    alter table(:players) do
      remove :games
      remove :ranking
      remove :provisional
    end
  end
end
