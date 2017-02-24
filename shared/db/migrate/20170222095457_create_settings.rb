class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.text :value, null: false, default: ''

      t.timestamps
    end

    add_index :settings, :key, unique: true
  end
end
