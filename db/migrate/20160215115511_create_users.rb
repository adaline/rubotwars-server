class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :key
      t.boolean :online, default: false
      t.string :next_move

      t.timestamps
    end
    add_index :users, :key
    add_index :users, :online
  end
end
