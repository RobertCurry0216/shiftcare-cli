# frozen_string_literal: true

require "json"

module Shiftcare
  module DataStores
    # Json store
    class JsonStore < BaseStore
      def initialize(filepath = nil)
        super()
        @data = []
        load_from_file!(filepath: filepath) unless filepath.nil?
      end

      def load_from_string!(raw)
        raise InvalidDataError, "JsonStore: Invalid raw data provided" unless raw.is_a? String

        @data = JSON.parse(raw)
      rescue JSON::ParserError => e
        raise InvalidDataError, "JsonStore: Invalid json => #{e.message}"
      end

      def load_from_file!(filepath: nil)
        raise InvalidDataError, "JsonStore: No file path provided" if filepath.nil?
        raise InvalidDataError, "JsonStore: File not found => #{filepath}" unless File.exist?(filepath)

        # TODO: this is not great for large files
        load_from_string!(File.read(filepath))
      end

      # Searches for all entries where the specified key's value contains the given substring (case-insensitive).
      #
      # @param key [String] The object key used to access the value in the stored entries.
      # @param value [String] The substring to search for within the key's values.
      #
      # @return [Array<Hash>] An array of matching entries
      def find_by(key, value)
        raise SearchValueError, "JsonStore: Invalid value provided => #{value}" unless value.is_a? String
        raise SearchValueError, "JsonStore: Invalid key provided => #{key}" unless key.is_a? String

        normalized_value = normalize(value)

        if normalized_value.empty?
          raise SearchValueError,
                "JsonStore: Provided search value does not contain any valid characters => \"#{value}\""
        end

        re = Regexp.new(Regexp.escape(normalized_value), Regexp::IGNORECASE)
        @data.find_all { |entry| re.match?(entry[key]) }
      end

      # Detects and returns entries that have duplicate normalized values for a given key.
      #
      # @param key [String] The field name to check for value collisions.
      #
      # @return [Array<Hash>] An array of all entries involved in collisions (groups with >1 entry)
      def find_collisions(key)
        raise SearchValueError, "JsonStore: Invalid key provided => #{key}" unless key.is_a? String

        hash = {}
        @data.each do |entry|
          normalized = normalize(entry[key])
          hash[normalized] ||= []
          hash[normalized] << entry
        end

        hash.values.filter { |entry_sets| entry_sets.length > 1 }.flatten
      end
    end
  end
end
