class AddCreditLimitToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :credit_limit_cents, :integer
  end
end
