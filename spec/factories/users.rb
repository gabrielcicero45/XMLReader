FactoryBot.define do
    factory :user do
      email { "foo@bar.com" }
      password { "password123" }
      password_confirmation { "password123" }
    end
  end