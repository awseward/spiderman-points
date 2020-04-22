class AddOptedOutToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.boolean :opted_out, null: false, default: false
    end
  end
end
