defmodule Pong.Repo.Migrations.AddReferencesToMatches do
  use Ecto.Migration

  def up do
    execute """
      ALTER TABLE ONLY matches
        ADD CONSTRAINT matches_player_a_fkey
        FOREIGN KEY (player_a_id) REFERENCES players(id);
    """
    
    execute """
      ALTER TABLE ONLY matches
        ADD CONSTRAINT matches_player_b_fkey
        FOREIGN KEY (player_b_id) REFERENCES players(id);
    """
  end

  def down do
    execute """
      ALTER TABLE ONLY matches DROP CONSTRAINT IF EXISTS matches_player_a_fkey;
    """
    
    execute """
      ALTER TABLE ONLY matches DROP CONSTRAINT IF EXISTS matches_player_b_fkey;
    """
  end
end
