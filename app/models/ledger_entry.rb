class LedgerEntry < ApplicationRecord
  belongs_to :account
  belongs_to :ledger_transaction

  validates :amount_cents, presence: true
  validates :entry_type, inclusion: { in: %w[debit credit] }
end
