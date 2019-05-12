# frozen_string_literal: true

require "logger"
require "issues/issue"

module PTBot
  module Issues
    class TestIssue < Minitest::Test
      def test_number
        assert_equal Issue.new(number: 7).number, 7
      end
    end
  end
end
