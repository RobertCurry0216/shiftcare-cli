# frozen_string_literal: true

require "faker"

def mock_profile(overrides = {})
  {
    "id" => Faker::Number.number,
    "full_name" => Faker::Name.name,
    "email" => Faker::Internet.email
  }.merge(overrides)
end
