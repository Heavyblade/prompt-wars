class CreateTimeOffTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :time_off_types do |t|
      t.string :name, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :time_off_types, :name, unique: true
  end
end

