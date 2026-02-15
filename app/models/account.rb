class Account < ApplicationRecord
  has_many :ledger_entries

  def balance_cents
    ledger_entries.sum(:amount_cents)
  end
end
