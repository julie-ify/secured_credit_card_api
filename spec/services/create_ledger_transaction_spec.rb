require "rails_helper"
RSpec.describe CreateLedgerTransaction do
  describe ".call" do
    let!(:a1) { create(:account) }
    let!(:a2) { create(:account) }

    context "when entries are unbalanced" do
      let(:entries) do
        [
          { account: a1, amount_cents: -1000, entry_type: "debit" },
          { account: a2, amount_cents: 1200, entry_type: "credit" }
        ]
      end

      it "raises UnbalancedLedgerError" do
        expect {
          described_class.call(reference: "tx_001", entries: entries)
        }.to raise_error(UnbalancedLedgerError)
    	end

      it "does not create any records" do
        expect {
          begin
            described_class.call(reference: "tx_001", entries: entries)
          rescue UnbalancedLedgerError
          end
        }.to change { LedgerTransaction.count }.by(0)
          .and change { LedgerEntry.count }.by(0)
      end
    end

    context "when entries are balanced" do
      let(:entries) do
        [
          { account: a1, amount_cents: -1000, entry_type: "debit" },
          { account: a2, amount_cents: 1000, entry_type: "credit" }
        ]
      end

      it "creates a ledger transaction" do
        expect {
          described_class.call(reference: "tx_002", entries: entries)
        }.to change(LedgerTransaction, :count).by(1)
      end

      it "creates ledger entries" do
        expect {
          described_class.call(reference: "tx_002", entries: entries)
        }.to change(LedgerEntry, :count).by(2)
      end

      it "links ledger entries to the transaction" do
        tx = described_class.call(reference: "tx_003", entries: entries)

        expect(tx.ledger_entries.pluck(:amount_cents))
          .to match_array([-1000, 1000])
      end
    end

    context "atomicity" do
      let(:entries) do
        []
      end

      it "rolls back if ledger entry creation fails" do
        expect {
          described_class.call(reference: "tx_004", entries: entries)
        }.to raise_error(ArgumentError)

        expect(LedgerTransaction.count).to eq(0)
        expect(LedgerEntry.count).to eq(0)
      end
    end
  end
end
