class AddMissingUniqueConstraints < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER TABLE users
        ADD CONSTRAINT no_duplicate_users UNIQUE (team_id, user_id);

      ALTER TABLE oauth_credentials
        ADD CONSTRAINT no_duplicate_credentials UNIQUE (team_id, app_id);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE users
        DROP CONSTRAINT IF EXISTS no_duplicate_users;

      ALTER TABLE oauth_credentials
        DROP CONSTRAINT IF EXISTS no_duplicate_credentials;
    SQL
  end
end
