class PostLedgerTransaction
  def self.call(ledger_transaction:)
    raise "Only pending transactions can be posted" unless ledger_transaction.pending?

    ledger_transaction.update!(status: 1) # posted
  end
end
