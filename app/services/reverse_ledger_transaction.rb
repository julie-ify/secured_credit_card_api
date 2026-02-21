class ReverseLedgerTransaction
  def self.call(ledger_transaction:)
    raise "Only pending transactions can be reversed" unless ledger_transaction.pending?

    ActiveRecord::Base.transaction do
      ledger_transaction.ledger_entries.each do |entry|
        LedgerEntry.create!(
          ledger_transaction: ledger_transaction,
          account: entry.account,
          amount_cents: -entry.amount_cents,
          entry_type: entry.entry_type
        )
      end

      ledger_transaction.update!(status: 3) # reversed
    end
  end
end
