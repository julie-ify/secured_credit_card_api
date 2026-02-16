class AddNotNullAndUniqueToAccountsName < ActiveRecord::Migration[7.1]
  def change
    change_column_null :accounts, :name, false
    add_index :accounts, :name, unique: true
  end
end
