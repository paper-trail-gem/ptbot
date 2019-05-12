# frozen_string_literal: true

require 'issues/issue'

module PTBot
  module Issues
    class NoTemplate < Issue
      private

      def detect_omissions
        [
          Omission.new(
            :no_template,
            "Issues must follow one of the provided templates"
          )
        ]
      end
    end
  end
end
