class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :team_id, null: false
      t.string :user_id, null: false

      t.timestamps
    end
  end
end
