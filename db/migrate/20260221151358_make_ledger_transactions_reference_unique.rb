class MakeLedgerTransactionsReferenceUnique < ActiveRecord::Migration[7.1]
  def change
    change_column_null :ledger_transactions, :reference, false

    # remove the existing non-unique index
    remove_index :ledger_transactions, :reference

    # add a unique index
    add_index :ledger_transactions, :reference, unique: true
  end
end
