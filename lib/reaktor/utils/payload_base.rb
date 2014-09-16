require 'logger'

module Reaktor
  module Utils
    class PayloadBase

      attr_reader :branch_name

      def initialize(payload)
        @payload = payload
      end
    end
  end
end
