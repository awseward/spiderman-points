class AddNoSelfAwardsCheckConstraint < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      -- First, capture any existing self-awarded points
      CREATE TABLE self_awarded_points (
        id         SERIAL PRIMARY KEY,
        team_id    TEXT NOT NULL,
        user_id    TEXT NOT NULL,
        reason     TEXT,
        created_at TIMESTAMP WITHOUT TIME ZONE,
        updated_at TIMESTAMP WITHOUT TIME ZONE
      );

      INSERT INTO self_awarded_points
              (team_id, user_id, reason, created_at, updated_at)
        SELECT team_id, from_id, reason, created_at, updated_at
        FROM points
        WHERE points.from_id = points.to_id;

      DELETE FROM points WHERE points.from_id = points.to_id;

      -- Add the constraint
      ALTER TABLE points ADD CONSTRAINT no_self_awards CHECK (to_id <> from_id);
    SQL
  end

  def down
    execute <<-SQL
      -- Drop the constraint
      ALTER TABLE points DROP CONSTRAINT IF EXISTS no_self_awards;

      -- Restore things to the way they were
      INSERT INTO points
              (team_id, from_id,   to_id, reason, created_at, updated_at)
        SELECT team_id, user_id, user_id, reason, created_at, updated_at
        FROM self_awarded_points;

      DROP TABLE self_awarded_points;
    SQL
  end
end
