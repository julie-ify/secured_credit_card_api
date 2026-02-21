class AddStatusToLedgerTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :ledger_transactions, :status, :integer, null: false, default: 0
    add_index :ledger_transactions, :status
  end
end
