require 'logger'
require 'utils/payload_base'

module Reaktor
  module Utils
    class StashPayload < Reaktor::Utils::PayloadBase
      attr_reader :branch_name
      attr_reader :ref_type
      attr_reader :repo_name
      attr_reader :created
      attr_reader :deleted

      def initialize(payload)
        @logger ||= Logger.new(STDOUT, Logger::INFO)
        super
        parse_json(payload)
      end

      def parse_json(payload)
        @repo_name = payload['repository']['name']
        repo_ref = payload['refChanges'][0]['refId']
        @created = created?(payload['refChanges'][0]['fromHash'])
        @deleted = deleted?(payload['refChanges'][0]['toHash'])
        ref_array = repo_ref.split('/')
        @ref_type = ref_array[1]
        @branch_name = ref_array[2]
      end

      def created?(before_hash)
        if before_hash =~ /^0+$/
          true
        else
          false
        end
      end

      def deleted?(after_hash)
        if after_hash =~ /^0+$/
          true
        else
          false
        end
      end
    end
  end
end
