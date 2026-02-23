class CreateLedgerTransaction
  def self.call(reference:, entries:)
    find_existing_tx(reference) || create_new_tx(reference, entries)
  end

  def self.create_new_tx(reference, entries)
    # Validates that the entries are provided and balanced.
    validate_entries!(entries)

    ActiveRecord::Base.transaction do
      # Validates that credit limits are not exceeded.
      enforce_credit_limits!(entries)

      create_transaction_with_entries(reference, entries)
    end
  rescue ActiveRecord::RecordNotUnique
    find_existing_tx(reference)
  end

  def self.find_existing_tx(reference)
    LedgerTransaction.find_by(reference: reference)
  end

  def self.validate_entries!(entries)
    raise ArgumentError, "Entries required" if entries.empty?
    raise UnbalancedLedgerError unless balanced?(entries)
  end

  # Checks that the sum of all entry amounts is zero,
  # ensuring the transaction is balanced.
  def self.balanced?(entries)
    entries.sum { |e| e[:amount_cents] }.zero?
  end

  def self.create_transaction_with_entries(reference, entries)
    tx = LedgerTransaction.create!(reference: reference, status: 0)

    entries.each do |entry|
      tx.ledger_entries.create!(
        account: entry[:account],
        amount_cents: entry[:amount_cents],
        entry_type: entry[:entry_type]
      )
    end

    tx
  end

  # Checks that for each debit entry, the associated account
  # has sufficient available credit to cover the amount.
  def self.enforce_credit_limits!(entries)
    entries
      .select { |e| e[:amount_cents].negative? }
      .each do |entry|
        account = entry[:account]
        amount = entry[:amount_cents].abs

        raise ActiveRecord::Rollback, "Credit limit exceeded" if
          account.available_credit_cents < amount
      end
  end
end

class UnbalancedLedgerError < StandardError; end
