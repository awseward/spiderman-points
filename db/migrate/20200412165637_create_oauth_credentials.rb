class CreateOauthCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :oauth_credentials do |t|
      t.string :app_id,         null: false
      t.string :team_id,        null: false
      t.string :access_token,   null: false
      t.string :scope,          null: false
      t.string :bot_user_id,    null: false
      t.string :authed_user_id, null: false

      t.timestamps
    end
  end
end
