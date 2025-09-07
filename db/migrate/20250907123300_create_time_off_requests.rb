class CreateTimeOffRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :time_off_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :time_off_type, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.text :reason
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :time_off_requests, [:user_id, :start_date, :end_date]
  end
end

