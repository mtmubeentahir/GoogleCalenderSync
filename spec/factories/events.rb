FactoryBot.define do
  factory :event do
    calendar { nil }
    google_id { 'MyString' }
    summary { 'MyString' }
    description { 'MyText' }
    start_time { '2024-09-20 01:04:23' }
    end_time { '2024-09-20 01:04:23' }
    location { 'MyString' }
    status { 'MyString' }
  end
end
