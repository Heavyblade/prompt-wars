class CreateApprovals < ActiveRecord::Migration[8.0]
  def change
    create_table :approvals do |t|
      t.references :time_off_request, null: false, foreign_key: true
      t.references :approver, null: false, foreign_key: {to_table: :users}
      t.integer :status, null: false, default: 0
      t.datetime :decided_at

      t.timestamps
    end
  end
end

