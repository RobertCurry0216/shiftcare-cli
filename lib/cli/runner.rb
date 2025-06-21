# frozen_string_literal: true

require "thor"

require_relative "../datastores/json_store"

module Shiftcare
  module Cli
    # TODO: Better comment
    # Cli runner
    class Runner < Thor
      def self.exit_on_failure?
        true
      end

      desc "search VALUE", "find user in provided json file"
      def search(value)
        type = CONFIG["store_type"]
        key = CONFIG.dig("schema", "name")
        puts DataStores.new(type).find_by(key, value)
      end

      desc "email_collisions", "find records with duplicated emails"
      def email_collisions
        type = CONFIG["store_type"]
        key = CONFIG.dig("schema", "email")
        puts DataStores.new(type).find_collisions(key)
      end
    end
  end
end
