class CreateLedgerTransaction
  def self.call(reference:, entries:)
    raise ArgumentError, "Entries required" if entries.empty?
    raise UnbalancedLedgerError unless entries.sum { |e| e[:amount_cents] }.zero?
    enforce_credit_limits!(entries)

    ActiveRecord::Base.transaction do
      tx = LedgerTransaction.create!(reference: reference)

      entries.each do |entry|
        tx.ledger_entries.create!(
          account: entry[:account],
          amount_cents: entry[:amount_cents],
          entry_type: entry[:entry_type]
        )
      end

      tx
    end
  end

  def self.enforce_credit_limits!(entries)
    debit_entries = entries.select { |e| e[:amount_cents] < 0 }

    debit_entries.each do |entry|
      account = entry[:account]
      amount  = entry[:amount_cents].abs

      if account.available_credit_cents < amount
        raise ActiveRecord::Rollback, "Credit limit exceeded"
      end
    end
  end
end

class UnbalancedLedgerError < StandardError; end
