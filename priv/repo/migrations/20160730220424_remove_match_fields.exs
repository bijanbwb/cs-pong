defmodule Pong.Repo.Migrations.RemoveMatchFields do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      remove :total_points
      remove :overtime
    end
  end
end
