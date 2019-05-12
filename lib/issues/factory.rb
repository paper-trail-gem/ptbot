# frozen_string_literal: true

require "issues/bug"
require "issues/feature"
require "issues/no_template"

module PTBot
  module Issues
    class Factory
      # Perhaps we should look for the checked box here. For now, maybe as long
      # as they follow the template that's good enough.
      FEATURE_COMMITMENT = "I am committed to building this feature myself"

      # Specifically not looking for a checked box next to this. They may be
      # having trouble writing a script, but as long as they follow the template
      # that's good enough.
      REPRODUCTION_SCRIPT = "This bug can be reproduced with the script I provide below"

      def build(data)
        unless data.is_a?(Hash)
          raise TypeError, "Expected Hash, got " + @data.class.name
        end
        issue_class(data.fetch(:body)).new(data)
      end

      private

      def issue_class(body)
        if body.include?(REPRODUCTION_SCRIPT)
          Bug
        elsif body.include?(FEATURE_COMMITMENT)
          Feature
        else
          NoTemplate
        end
      end
    end
  end
end
