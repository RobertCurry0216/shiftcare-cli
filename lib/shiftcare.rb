# frozen_string_literal: true

require_relative "cli/runner"

module Shiftcare
  VERSION = "0.1.0"
end

def main
  Shiftcare::Cli::Runner.start(ARGV)
end

main if __FILE__ == $PROGRAM_NAME
