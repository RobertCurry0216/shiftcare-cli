# frozen_string_literal: true

require "json"
require_relative "./base_store"

module Shiftcare
  module DataStores

    # Json store
    class JsonStore < BaseStore
      def initialize(filepath = nil)
        super()
        @data = {}
        @data_is_valid = false
        load_from_file!(filepath: filepath) unless filepath.nil?
      end

      def load_from_string!(raw)
        @data = JSON.parse(raw)
        @data_is_valid = true
      rescue JSON::ParserError => e
        raise InvalidDataError, "JsonStore: Invalid json => #{e.message}"
      end

      def load_from_file!(filepath: nil)
        raise InvalidDataError, "JsonStore: No file path provided" if filepath.nil?
        raise InvalidDataError, "JsonStore: File not found => #{filepath}" unless File.exist?(filepath)

        # TODO: this is not great for large files
        load_from_string!(File.read(filepath))
      end

      def search(value)
        raise InvalidDataError, "JsonStore: Data has not been validated" unless @data_is_valid

        normalized_value = normalize(value)

        raise SearchValueError, "JsonStore: Provided search value does not contain any valid characters => \"#{value}\"" if normalized_value.empty?

        re = Regexp.new(Regexp.escape(normalized_value), Regexp::IGNORECASE)
        @data.find_all { |entry| re.match?(entry["full_name"]) }
      end

      def validate_emails
        raise InvalidDataError, "JsonStore: Data has not been validated" unless @data_is_valid

        hash = {}
        @data.each do |entry|
          normalized = normalize(entry["email"])
          hash[normalized] ||= []
          hash[normalized] << entry
        end

        hash.values.filter { |entry_sets| entry_sets.length > 1 }
      end
    end
  end
end
