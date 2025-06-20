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

      desc "search", "find user in provided json file"
      method_option :value, required: true, aliases: :v, type: :string
      method_option :filepath, required: true, aliases: :f, type: :string
      def search
        puts DataStores::JsonStore.new(options["filepath"]).search(options["value"])
      end

      desc "validate", "find records with duplicated emails"
      method_option :filepath, required: true, aliases: :f, type: :string
      def validate
        puts DataStores::JsonStore.new(options["filepath"]).validate_emails
      end
    end
  end
end
