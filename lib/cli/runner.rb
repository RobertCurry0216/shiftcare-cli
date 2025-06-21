# frozen_string_literal: true

require "thor"

require_relative "../datastores/core"

module Shiftcare
  module Cli
    class Runner < Thor
      def self.exit_on_failure?
        true
      end

      class_option :verbose, type: :boolean, aliases: :v, desc: "Show long error messages"

      desc "config", "update the filepath for the json datastore"
      option :filepath, aliases: :f, desc: "filepath to json file", type: :string, required: true
      def config
        return warn "Could not find file: #{option["filepath"]}" unless File.exist?(options["filepath"])
        return warn "Could not find config file" unless File.exist?(CONFIG_PATH)

        config_copy = CONFIG.clone
        config_copy["filepath"] = options["filepath"]

        File.write(CONFIG_PATH, YAML.dump(config_copy))
        puts "Datastore filepath successfully updated!"
      rescue DataStores::StoreError => e
        raise e if options["verbose"]

        warn "Search failed", e.message
      end

      desc "search VALUE", "find records where full_name partially matches given text"
      long_desc <<~DESC
        Returns the complete records for records who's name partially matches the provided text.

        Search will ignore case and leading/trailing whitespace.
      DESC
      def search(value)
        type = CONFIG["store_type"]
        key = CONFIG.dig("schema", "name")
        puts DataStores.new(type).find_by(key, value)
      rescue DataStores::StoreError => e
        raise e if options["verbose"]

        warn "Search failed", e.message
      end

      desc "email_collisions", "find records with duplicated emails"
      long_desc <<~DESC
        Returns the complete records for records who have an email that appears more than once in the datastore

        Emails will be compared ignoring case and leading/trailing whitespace.
      DESC
      def email_collisions
        type = CONFIG["store_type"]
        key = CONFIG.dig("schema", "email")
        puts DataStores.new(type).find_collisions(key)
      rescue DataStores::StoreError => e
        raise e if options["verbose"]

        warn "email_collisions failed", e.message
      end
    end
  end
end
