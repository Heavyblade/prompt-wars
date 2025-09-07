class AddProfileAndRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :department, foreign_key: true, null: true
    add_reference :users, :manager, foreign_key: {to_table: :users}, null: true
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :role, :integer, default: 0, null: false
    add_index :users, :role
  end
end

