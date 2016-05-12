FactoryGirl.define do

  factory :user do
    sequence(:login) {|n| "random.user.#{n}.#{Time.now.to_i}" }
    sequence(:mail) {|n| "someuser#{n}-#{Time.now.to_i}@example.com"   }

    firstname "User"
    lastname "Name"

    password  "test123!"
    password_confirmation  "test123!"
  end

end