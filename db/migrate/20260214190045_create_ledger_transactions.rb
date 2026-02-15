class CreateLedgerTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :ledger_transactions do |t|
      t.string :reference

      t.timestamps
    end
    add_index :ledger_transactions, :reference
  end
end
