class CreateLedgerEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :ledger_entries do |t|
      t.references :account, null: false, foreign_key: true
      t.references :ledger_transaction, null: false, foreign_key: true
      t.integer :amount_cents
      t.string :entry_type

      t.timestamps
    end
  end
end
