# frozen_string_literal: true

require "json"
require_relative "helpers"

RSpec.describe Shiftcare::DataStores::JsonStore do
  describe "#find_by" do
    let!(:profile_with_special_characters) do
      mock_profile({ "full_name" => "~?X-Special::Name-X?~" })
    end

    let!(:profile_with_jane_a) do
      mock_profile({ "full_name" => "Bob Jane" })
    end

    let!(:profile_with_jane_b) do
      mock_profile({ "full_name" => "Mary Mcjaneson" })
    end

    let!(:profile_with_missing_data) do
      mock_profile({ "email" => nil })
    end

    let!(:json_data) do
      [
        profile_with_jane_a,
        profile_with_jane_b,
        profile_with_special_characters,
        mock_profile,
        mock_profile,
        mock_profile,
        mock_profile,
        profile_with_missing_data,
        mock_profile({ "full_name" => nil })
      ]
    end

    let!(:store) do
      store = described_class.new
      store.load_from_string!(JSON.dump(json_data))
      store
    end

    context "Should succeed" do
      it "finds a profile when given a value that exists" do
        expected = profile_with_jane_a

        result = store.find_by("full_name", expected["full_name"])

        expect(result.length).to eq(1)
        expect(result.first).to match(expected)
      end

      it "finds a profile when given a value that exists and different casing with extra padding" do
        expected = profile_with_jane_a

        result = store.find_by("full_name", "   #{expected["full_name"].upcase}   ")

        expect(result.length).to eq(1)
        expect(result.first).to match(expected)
      end

      it "returns nothing when given a value that does not exist" do
        result = store.find_by("full_name", "__Non-existent-name__")

        expect(result.length).to eq(0)
      end

      it "returns multiple uses when given a partial name" do
        expected = [profile_with_jane_a, profile_with_jane_b]

        result = store.find_by("full_name", "jane")

        expect(result.length).to eq(2)
        expect(result).to match(expected)
      end

      it "can handle a value containing special characters" do
        expected = profile_with_special_characters

        result = store.find_by("full_name", expected["full_name"])

        expect(result.length).to eq(1)
        expect(result.first).to match(expected)
      end

      it "gracefully handles profiles with missing data" do
        expected = profile_with_missing_data

        result = store.find_by("full_name", expected["full_name"])

        expect(result.length).to eq(1)
        expect(result.first).to match(expected)
      end
    end

    context "Should fail" do
      it "when given a value containing no printable characters" do
        expect { store.find_by("full_name", "  ") }.to raise_error(Shiftcare::DataStores::SearchValueError)
      end

      it "when given nil for the value" do
        expect { store.find_by("full_name", nil) }.to raise_error(Shiftcare::DataStores::SearchValueError)
      end

      it "when given nil for the key" do
        expect { store.find_by(nil, "bob") }.to raise_error(Shiftcare::DataStores::SearchValueError)
      end

      it "when given a non-string for the value" do
        expect { store.find_by("full_name", 123) }.to raise_error(Shiftcare::DataStores::SearchValueError)
      end

      it "when given a non-string for the key" do
        expect { store.find_by(123, "bob") }.to raise_error(Shiftcare::DataStores::SearchValueError)
      end
    end
  end

  describe "#find_collisions" do
    let!(:profiles_with_email_a) do
      # mixed casing to test normalization
      [
        mock_profile({ "email" => "a_email@collision.com" }),
        mock_profile({ "email" => "A_EMail@Collision.Com" })
      ]
    end

    let!(:profiles_with_email_b) do
      [
        mock_profile({ "email" => "b_email@collision.com" }),
        mock_profile({ "email" => "b_email@collision.com" }),
        mock_profile({ "email" => "b_email@collision.com" })
      ]
    end

    let!(:profiles_with_unique_emails) do
      [
        mock_profile,
        mock_profile,
        mock_profile
      ]
    end

    let!(:profiles_with_missing_data) do
      [
        mock_profile({ "email" => nil })
      ]
    end

    context "Should succeed" do
      it "with a no collisions" do
        store = described_class.new
        store.load_from_string!(JSON.dump(profiles_with_unique_emails))

        result = store.find_collisions("email")

        expect(result.length).to eq(0)
      end

      it "with a single collision" do
        store = described_class.new
        store.load_from_string!(JSON.dump(profiles_with_email_a + profiles_with_unique_emails))

        expected = profiles_with_email_a

        result = store.find_collisions("email")

        expect(result.length).to eq(expected.length)
        expect(result).to match(expected)
      end

      it "with a multiple collisions" do
        store = described_class.new
        store.load_from_string!(
          JSON.dump(profiles_with_email_a + profiles_with_unique_emails + profiles_with_email_b)
        )

        expected = profiles_with_email_a + profiles_with_email_b

        result = store.find_collisions("email")

        expect(result.length).to eq(expected.length)
        expect(result).to match(expected)
      end

      it "gracefully handles missing data" do
        store = described_class.new
        store.load_from_string!(JSON.dump(profiles_with_unique_emails + profiles_with_missing_data))

        result = store.find_collisions("email")

        expect(result.length).to eq(0)
      end
    end

    context "Should fail" do
      it "when given a non-string for the key" do
        store = described_class.new
        expect { store.find_collisions(123) }.to raise_error(Shiftcare::DataStores::SearchValueError)
      end
    end
  end
end
