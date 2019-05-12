# frozen_string_literal: true

require 'issues/issue'

module PTBot
  module Issues
    class Bug < Issue
      REQUIRE_BUNDLER_INLINE = 'require "bundler/inline"'

      private

      def detect_omissions
        [
          omission_of_bundler_inline
        ].compact
      end

      def omission_of_bundler_inline
        unless include?(REQUIRE_BUNDLER_INLINE)
          Omission.new(
            :reproduction_script,
            'Reproduction script must use bundler/inline'
          )
        end
      end
    end
  end
end
