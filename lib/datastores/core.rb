# frozen_string_literal: true

require_relative "base_store"
require_relative "json_store"

module Shiftcare
  module DataStores
    class StoreError < StandardError; end
    class InvalidDataError < StoreError; end
    class SearchValueError < StoreError; end

    def self.new(type)
      case type
      when "json"
        JsonStore.new(CONFIG["filepath"])
      else
        raise StoreError, "Invalid store type: #{type}"
      end
    end
  end
end
