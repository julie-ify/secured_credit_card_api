class CreateLedgerTransaction
  def self.call(reference:, entries:)
    raise ArgumentError, "Entries required" if entries.empty?
    raise UnbalancedLedgerError unless entries.sum { |e| e[:amount_cents] }.zero?

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
end

class UnbalancedLedgerError < StandardError; end
