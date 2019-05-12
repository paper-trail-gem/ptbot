# frozen_string_literal: true

require 'issues/issue'

module PTBot
  module Issues
    class Feature < Issue
      DESCRIBE_SOLUTION = "Describe the solution you'd like to build"

      private

      def detect_omissions
        [
          omission_of_solution_description
        ].compact
      end

      def omission_of_solution_description
        unless include?(DESCRIBE_SOLUTION)
          Omission.new(
            :description_of_solution,
            "Must use section headers from the template"
          )
        end
      end
    end
  end
end
