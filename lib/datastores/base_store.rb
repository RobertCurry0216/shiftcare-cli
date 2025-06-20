# frozen_string_literal: true

module Shiftcare
  module DataStores
    class StoreError < StandardError; end
    class InvalidDataError < StandardError; end
    class SearchValueError < StandardError; end

    # Abstract base class for data stores
    class BaseStore
      def search(_value)
        raise StoreError "Method Not Implemented: search"
      end

      def validate_emails
        raise StoreError "Method Not Implemented: validate_emails"
      end

      def normalize(value)
        value.strip.downcase
      end
    end
  end
end
