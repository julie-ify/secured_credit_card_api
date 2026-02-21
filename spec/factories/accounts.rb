FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Account #{n}" }
    credit_limit_cents { 10_000 }
  end
end
