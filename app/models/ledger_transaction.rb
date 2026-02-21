class LedgerTransaction < ApplicationRecord
  has_many :ledger_entries

  validates :reference, presence: true, uniqueness: true

  enum :status, { pending: 0, posted: 1, reversed: 2 }
end

