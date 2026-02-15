class LedgerTransaction < ApplicationRecord
  has_many :ledger_entries
  validates :reference, presence: true, uniqueness: true
end

