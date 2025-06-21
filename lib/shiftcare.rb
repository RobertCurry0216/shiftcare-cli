# frozen_string_literal: true

require_relative "cli/runner"
require "yaml"

module Shiftcare
  VERSION = "0.1.0"
  CONFIG_PATH = File.expand_path(File.join(__dir__, "..", "config", "cli.yml"))
  CONFIG = YAML.load_file(CONFIG_PATH)
end

def main
  Shiftcare::Cli::Runner.start(ARGV)
end

main if __FILE__ == $PROGRAM_NAME
