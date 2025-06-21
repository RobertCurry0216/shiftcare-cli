# frozen_string_literal: true

module Shiftcare
  module DataStores
    class StoreError < StandardError; end
    class InvalidDataError < StandardError; end
    class SearchValueError < StandardError; end

    def self.new(type)
      case type
      when "json"
        JsonStore.new(CONFIG["filepath"])
      else
        raise StoreError, "Invalid store type: #{type}"
      end
    end

    # Abstract base class for data stores
    class DataStore
      def find_by(_key, _value)
        raise StoreError "Method Not Implemented: find"
      end

      def find_collisions(_key)
        raise StoreError "Method Not Implemented: find_collisions"
      end

      # Utility fn to normalize strings for searching
      def normalize(value)
        value.strip.downcase
      end
    end
  end
end
