# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    user nil
    blog nil
    active false
    role 1
    token "MyString"
  end
end
