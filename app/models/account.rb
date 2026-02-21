class Account < ApplicationRecord
  has_many :ledger_entries, dependent: :destroy

  validates :credit_limit_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true, uniqueness: true

  # Balance is the sum of all posted entries for this account
  def balance_cents
    posted_entries.sum(:amount_cents)
  end

  # Available credit is the credit limit minus the sum of pending debits and the current balance
  def available_credit_cents
    credit_limit_cents - pending_debits_cents + balance_cents
  end

  # Sum of pending debit entries (negative amounts) for this account
  def pending_debits_cents
    pending_entries
      .where("amount_cents < 0")
      .sum("ABS(amount_cents)")
  end

  private

  def posted_entries
    ledger_entries.joins(:ledger_transaction)
                  .where(ledger_transactions: { status: 1 }) # posted
  end

  def pending_entries
    ledger_entries.joins(:ledger_transaction)
                  .where(ledger_transactions: { status: 0 }) # pending
  end
end
