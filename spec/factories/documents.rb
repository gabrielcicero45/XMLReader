FactoryBot.define do
    factory :document do
      association :user
      processed { false } 
  
      trait :processed do
        processed { true }
      end
    end
  end