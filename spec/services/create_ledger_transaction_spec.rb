require "rails_helper"
RSpec.describe CreateLedgerTransaction do
  describe ".call" do
    let!(:customer) { create(:account) }
    let!(:merchant) { create(:account) }

    context "when entries are unbalanced" do
      let(:entries) do
        [
          { account: customer, amount_cents: -1000, entry_type: "debit" },
          { account: merchant, amount_cents: 1200, entry_type: "credit" }
        ]
      end

      it "raises UnbalancedLedgerError" do
        expect do
          described_class.call(reference: "tx_001", entries: entries)
        end.to raise_error(UnbalancedLedgerError)
      end

      it "does not create any transaction records" do
        expect do
          described_class.call(reference: "tx_001", entries: entries)
        end.to raise_error(UnbalancedLedgerError).and change(LedgerTransaction, :count).by(0)
      end
    end

    context "when entries are balanced" do
      let(:entries) do
        [
          { account: customer, amount_cents: -1000, entry_type: "debit" },
          { account: merchant, amount_cents: 1000, entry_type: "credit" }
        ]
      end

      it "creates a ledger transaction" do
        expect do
          described_class.call(reference: "tx_002", entries: entries)
        end.to change(LedgerTransaction, :count).by(1)
      end

      it "creates ledger entries" do
        expect do
          described_class.call(reference: "tx_002", entries: entries)
        end.to change(LedgerEntry, :count).by(2)
      end

      it "links ledger entries to the transaction" do
        tx = described_class.call(reference: "tx_003", entries: entries)

        expect(tx.ledger_entries.pluck(:amount_cents))
          .to contain_exactly(-1000, 1000)
      end
    end

    context "when no entries are provided" do
      let(:entries) do
        []
      end

      it "raises an ArgumentError" do
        expect do
          described_class.call(reference: "tx_004", entries: entries)
        end.to raise_error(ArgumentError)
      end

      it "rolls back transaction if ledger entry creation fails" do
        expect do
          described_class.call(reference: "tx_004", entries: entries)
        end.to raise_error(ArgumentError).and change(LedgerTransaction, :count).by(0)
      end
    end
  end
end
