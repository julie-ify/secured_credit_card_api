class Account < ApplicationRecord
  has_many :ledger_entries

  validates :credit_limit_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true, uniqueness: true

  def balance_cents
    ledger_entries.sum(:amount_cents)
  end

  def available_credit_cents
    credit_limit_cents + balance_cents
  end
end
