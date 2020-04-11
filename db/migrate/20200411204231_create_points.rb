class CreatePoints < ActiveRecord::Migration[5.2]
  def change
    create_table :points do |t|
      t.string :team_id, null: false
      t.string :from_id, null: false
      t.string :to_id,   null: false
      t.string :reason,  null: true

      t.timestamps
    end
  end
end
