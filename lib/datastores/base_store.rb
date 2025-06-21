# frozen_string_literal: true

module Shiftcare
  module DataStores
    # Abstract base class for data stores
    class BaseStore
      def find_by(_key, _value)
        raise StoreError "Method Not Implemented: find"
      end

      def find_collisions(_key)
        raise StoreError "Method Not Implemented: find_collisions"
      end

      # Utility fn to normalize strings when searching
      def normalize(value)
        value&.strip&.downcase || ""
      end
    end
  end
end
